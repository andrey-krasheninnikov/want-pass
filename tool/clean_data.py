"""Reset only the current application's local vault and appearance settings."""
import fcntl
import os
from pathlib import Path
import stat
import subprocess

BUNDLE_ID = "foundation.want.pass"

def targets(home):
    return [home / "Library/Application Support" / BUNDLE_ID,
            home / "Library/Containers" / BUNDLE_ID / "Data/Library/Application Support" / BUNDLE_ID]

def fingerprint(path):
    value = path.lstat()
    if stat.S_ISLNK(value.st_mode) or not stat.S_ISREG(value.st_mode) or value.st_uid != os.getuid():
        raise RuntimeError("Unsafe data file; reset refused")
    return (value.st_dev, value.st_ino, value.st_size, value.st_mtime_ns)

def clean(home):
    snapshots = {}
    descriptors = []
    try:
        for root in targets(home):
            if not root.exists() and not root.is_symlink():
                continue
            for parent in [root, *root.parents]:
                if parent.is_symlink():
                    raise RuntimeError("Symlink in data path; reset refused")
            if root.lstat().st_uid != os.getuid() or not root.is_dir():
                raise RuntimeError("Data directory ownership mismatch")
            if any(p.name not in {"vault", "appearance.json", "appearance.tmp"} for p in root.iterdir()):
                raise RuntimeError("Unknown application files; reset refused")
            vault = root / "vault"
            if vault.exists() or vault.is_symlink():
                if not vault.is_dir() or vault.is_symlink() or vault.lstat().st_uid != os.getuid():
                    raise RuntimeError("Unsafe vault directory")
                if any(p.name not in {"vault.wpass", "vault.lock"} for p in vault.iterdir()):
                    raise RuntimeError("Unknown vault files; reset refused")
            files = [p for p in [root / "appearance.json", root / "appearance.tmp", vault / "vault.wpass"] if p.exists() or p.is_symlink()]
            snapshots.update({p: fingerprint(p) for p in files})
            lock = vault / "vault.lock"
            if lock.exists() or lock.is_symlink():
                fingerprint(lock)
                descriptor = os.open(lock, os.O_RDWR | os.O_NOFOLLOW)
                descriptors.append(descriptor)
                fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
            elif (vault / "vault.wpass").exists():
                raise RuntimeError("Vault lock missing; reset refused")
        for path, expected in snapshots.items():
            if fingerprint(path) != expected:
                raise RuntimeError("Data changed during reset; reset stopped")
        for path in snapshots:
            path.unlink()
        # Keep each lock inode stable so a new process cannot bypass the lock.
        return len(snapshots)
    finally:
        for descriptor in descriptors:
            os.close(descriptor)

if __name__ == "__main__":
    if subprocess.run(["/usr/bin/pgrep", "-x", "Want Pass"], capture_output=True).returncode == 0:
        raise SystemExit("Close Want Pass before resetting local data.")
    try:
        print(f"Removed {clean(Path.home())} application data files. Exports and old bundle data are preserved.")
    except (OSError, RuntimeError):
        raise SystemExit("Reset refused: application busy, unsafe path or unknown files. No broad cleanup was attempted.")
