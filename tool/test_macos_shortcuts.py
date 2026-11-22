"""Build and run the cursor-panel smoke in a disposable macOS application bundle."""
import pathlib
import plistlib
import subprocess
import sys
import tempfile
import uuid


def main() -> int:
    if sys.platform != "darwin":
        raise SystemExit("Requires a logged-in macOS desktop.")
    root = pathlib.Path(__file__).resolve().parents[1]
    engine = root / ".fvm/flutter_sdk/bin/cache/artifacts/engine/darwin-x64-release"
    framework = (engine / "FlutterMacOS.xcframework/macos-arm64_x86_64").resolve()
    if not (framework / "FlutterMacOS.framework").is_dir():
        raise SystemExit("Run fvm flutter precache --macos.")
    with tempfile.TemporaryDirectory(prefix="want-pass-shortcut-smoke-") as tmp:
        directory = pathlib.Path(tmp)
        contents = directory / "Shortcut Fixture.app/Contents"
        executable = contents / "MacOS/ShortcutFixture"
        executable.parent.mkdir(parents=True)
        bundle_id = "foundation.want.pass.shortcut-smoke." + uuid.uuid4().hex
        with (contents / "Info.plist").open("wb") as stream:
            plistlib.dump({"CFBundleIdentifier": bundle_id, "CFBundleExecutable": executable.name,
                           "CFBundleName": "Shortcut Fixture", "CFBundlePackageType": "APPL",
                           "CFBundleVersion": "1", "LSUIElement": True}, stream)
        subprocess.run(["xcrun", "swiftc", "-F", str(framework), "-framework", "FlutterMacOS",
                        "-Xlinker", "-rpath", "-Xlinker", str(framework),
                        "-module-cache-path", str(directory / "modules"),
                        str(root / "apps/want_pass/macos/Runner/VaultShortcutHost.swift"),
                        str(root / "tool/shortcut_smoke.swift"), "-o", str(executable)], check=True)
        return subprocess.run([str(executable)], check=False, timeout=30).returncode


if __name__ == "__main__":
    sys.exit(main())
