import fcntl
import os
from pathlib import Path
import tempfile
import unittest
from clean_data import clean, targets

class CleanDataTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name).resolve()
        self.root = targets(self.home)[0]
        (self.root / "vault").mkdir(parents=True)
        for name in ["vault.wpass", "vault.lock"]:
            (self.root / "vault" / name).write_bytes(b"synthetic")
        (self.root / "appearance.json").write_text("{}")
    def test_reset_preserves_exports_and_old_namespace(self):
        export = self.home / "recovery.txt"; export.write_text("synthetic")
        old = self.root.parent / "io.github.andreykrasheninnikov.wantPass"
        old.mkdir(); (old / "keep").write_text("synthetic")
        self.assertEqual(clean(self.home), 2)
        self.assertTrue((self.root / "vault/vault.lock").exists())
        self.assertTrue(export.exists()); self.assertTrue((old / "keep").exists())
        self.assertEqual(clean(self.home), 0)
    def test_all_namespaces_are_validated_before_deleting(self):
        second = targets(self.home)[1]
        second.mkdir(parents=True)
        (second / "unknown").write_text("synthetic")
        with self.assertRaises(RuntimeError): clean(self.home)
        self.assertTrue((self.root / "vault/vault.wpass").exists())
    def test_dangling_vault_symlink_preserves_preferences(self):
        root = targets(self.home)[1]
        root.mkdir(parents=True)
        (root / "appearance.json").write_text("{}")
        (root / "vault").symlink_to(self.home / "missing-vault", target_is_directory=True)
        with self.assertRaises(RuntimeError): clean(self.home)
        self.assertTrue((root / "appearance.json").exists())
        self.assertTrue((self.root / "vault/vault.wpass").exists())
    def test_busy_unknown_and_symlink_are_refused(self):
        with (self.root / "vault/vault.lock").open("r+") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with self.assertRaises(OSError): clean(self.home)
        unknown = self.root / "keep"; unknown.write_text("synthetic")
        with self.assertRaises(RuntimeError): clean(self.home)
        unknown.unlink()
        hint = self.root / "appearance.json"; hint.unlink(); hint.symlink_to(self.home / "elsewhere")
        with self.assertRaises(RuntimeError): clean(self.home)
        self.assertTrue((self.root / "vault/vault.wpass").exists())

if __name__ == "__main__": unittest.main()
