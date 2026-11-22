#!/usr/bin/env python3
"""Test the signed helper and an OpenSSH alias against a loopback-only peer."""

import json
import os
from pathlib import Path
import pty
import re
import secrets
import shutil
import signal
import subprocess
import tempfile
import time

REPO = Path(__file__).resolve().parent.parent
APP = REPO / "apps/want_pass"
SWIFT = APP / "macos"
TOOL = REPO / "tool"
CONTAINER = Path.home() / "Library/Containers/foundation.want.pass.dev/Data"
ALIAS = "acceptance-loopback"
MARKER = b"want-pass-loopback-ok"


def wait_for(path, process, timeout):
    deadline = time.monotonic() + timeout
    while not path.exists():
        if process.poll() is not None or time.monotonic() >= deadline:
            raise RuntimeError("Fixture did not reach " + path.name)
        time.sleep(0.1)


def command(args, tty=False):
    master, slave = pty.openpty() if tty else (None, None)
    try:
        child = subprocess.Popen(
            args,
            stdin=slave if tty else subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            start_new_session=True,
        )
        try:
            out, _ = child.communicate(timeout=45)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid, signal.SIGKILL)
            child.communicate()
            raise RuntimeError("Timed out running " + Path(args[0]).name) from None
        if child.returncode:
            raise RuntimeError(f"{Path(args[0]).name} exited {child.returncode}")
        return out
    finally:
        if tty:
            os.close(slave)
            os.close(master)


def stop(process):
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()


def run_fixture(work, fixture):
    shutil.copyfile(TOOL / "fixtures/ssh_peer.go", work / "main.go")
    (work / "go.mod").write_text(
        "module want.foundation/pass/ssh-fixture\n\ngo 1.25.0\n\nrequire golang.org/x/crypto v0.54.0\n"
    )
    subprocess.run(
        ["go", "build", "-mod=mod", "-o", work / "ssh-peer", "."],
        check=True,
        cwd=work,
        env=dict(os.environ, GOWORK="off"),
    )
    subprocess.run(
        [
            "xcrun",
            "swiftc",
            SWIFT / "Shared/LocalToolsTransport.swift",
            SWIFT / "wpass/SSHConfiguration.swift",
            TOOL / "fixtures/ssh_alias.swift",
            "-o",
            work / "alias",
        ],
        check=True,
    )
    flutter = None
    pinned = None
    expected_pin = None
    server = subprocess.Popen([work / "ssh-peer", fixture])
    try:
        wait_for(fixture / "server.json", server, 10)
        flutter = subprocess.Popen(
            [
                "fvm",
                "flutter",
                "test",
                "--no-pub",
                "integration_test/local_tools_ipc_test.dart",
                "-d",
                "macos",
                "--reporter",
                "expanded",
                "--dart-define=WPASS_SSH_FIXTURE=" + str(fixture),
            ],
            cwd=APP,
        )
        wait_for(fixture / "ready.json", flutter, 360)
        ready = json.loads((fixture / "ready.json").read_text())
        options = json.loads((fixture / "server.json").read_text())
        cli = Path(ready["cli"]).resolve()
        expected_cli = (
            APP
            / "build/macos/Build/Products/Debug/Want Pass Dev.app/Contents/Helpers/wpass"
        )
        if cli != expected_cli.resolve() or not re.fullmatch(
            r"[0-9a-f]{32}", ready["id"]
        ):
            raise RuntimeError("Unexpected development helper or fixture profile")
        command([cli, "authorize", "ssh", ALIAS])
        public = command([cli, "public-key", ALIAS])
        if not public.startswith(b"ssh-ed25519 ") or len(public) > 1024:
            raise RuntimeError("Unexpected public identity")
        (fixture / "authorized.pub").write_bytes(public)
        pinned = CONTAINER / ".wpass" / ("h-" + ready["id"])
        expected_pin = (
            f"[127.0.0.1]:{options['port']} {options['public_key']}\n"
        ).encode()
        print("Connecting the signed helper to the loopback peer.", flush=True)
        if MARKER not in command([cli, "ssh", ALIAS], tty=True):
            raise RuntimeError("Interactive helper did not authenticate")
        command([work / "alias", fixture])
        config = fixture / ".ssh/config"
        if not config.is_file():
            raise RuntimeError(
                "The fixture did not create its approved SSH configuration"
            )
        effective = command(["/usr/bin/ssh", "-G", "-F", config, ALIAS])
        if (
            b"hostname 127.0.0.1\n" not in effective
            or b"user fixture\n" not in effective
            or b"\nproxycommand " in effective
        ):
            raise RuntimeError("System OpenSSH did not resolve the fixture alias")
        if server.poll() is not None:
            raise RuntimeError("Loopback peer ended before the second connection")
        print("Connecting system OpenSSH using the temporary alias.", flush=True)
        if MARKER not in command(
            ["/usr/bin/ssh", "-T", "-F", fixture / ".ssh/config", ALIAS]
        ):
            raise RuntimeError("OpenSSH alias did not authenticate")
        (fixture / "finished").write_text("passed")
        if flutter.wait(timeout=45) != 0 or server.wait(timeout=10) != 0:
            raise RuntimeError("Fixture did not close cleanly")
        print("Both connections authenticated to the isolated loopback peer.")
    finally:
        stop(flutter)
        stop(server)
        if (
            pinned
            and pinned.is_file()
            and not pinned.is_symlink()
            and pinned.read_bytes() == expected_pin
        ):
            pinned.unlink()


def main():
    if (
        not CONTAINER.is_dir()
        or CONTAINER.is_symlink()
        or CONTAINER.stat().st_uid != os.getuid()
    ):
        raise RuntimeError("Build the macOS development application first.")
    with tempfile.TemporaryDirectory(prefix="want-pass-loopback-") as local:
        fixture = CONTAINER / (".wpass-test-" + secrets.token_hex(6))
        fixture.mkdir(mode=0o700)
        try:
            run_fixture(Path(local), fixture)
        finally:
            shutil.rmtree(fixture)


if __name__ == "__main__":
    main()
