"""Prepare, notarize and verify the direct Universal 2 macOS release."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import fnmatch
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import uuid


ROOT = Path(__file__).resolve().parents[1]
BUNDLE_ID = "foundation.want.pass"
PROFILE = "want-pass-notary"
ARCHS = {"arm64", "x86_64"}
MACH_MAGIC = {
    bytes.fromhex(value) for value in
    ("feedface", "cefaedfe", "feedfacf", "cffaedfe", "cafebabe", "bebafeca", "cafebabf", "bfbafeca")
}


def require(condition, explanation):
    if not condition:
        raise ValueError(explanation)


def run(*args, capture=False):
    return subprocess.run(
        list(map(str, args)), check=True,
        stdout=subprocess.PIPE if capture else None,
    ).stdout


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def release_version():
    manifest = (ROOT / "apps/want_pass/pubspec.yaml").read_text()
    version = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", manifest, re.M)
    require(version, "Expected a version and build number in pubspec.yaml")
    return version.groups()


def identity_team(identity):
    match = re.fullmatch(r"Developer ID Application: .+ \(([A-Z0-9]{10})\)", identity or "")
    require(match, "Set WANT_PASS_DEVELOPER_ID to the complete Developer ID Application identity.")
    return match.group(1)


def code_objects(app):
    binaries, bundles = [], []
    for item in app.rglob("*"):
        if item.is_symlink():
            require(item.resolve(strict=True).is_relative_to(app), "Bundle link leaves its directory: " + str(item))
        elif item.is_dir() and item.suffix in (".app", ".xpc", ".appex", ".framework", ".plugin", ".bundle"):
            if item.suffix == ".bundle":
                info = item / "Contents/Info.plist"
                if not info.is_file() or not plistlib.loads(info.read_bytes()).get("CFBundleExecutable"):
                    continue
            bundles.append(item)
        elif item.is_file():
            with item.open("rb") as source:
                if source.read(4) in MACH_MAGIC:
                    binaries.append(item)
    return binaries, sorted(bundles, key=lambda path: len(path.parts), reverse=True)


def inspect_layout(app, need_helper=True):
    app = app.resolve(strict=True)
    version, build = release_version()
    info = plistlib.loads((app / "Contents/Info.plist").read_bytes())
    require(app.name == "Want Pass.app" and info.get("CFBundleIdentifier") == BUNDLE_ID,
            "Expected the production Want Pass.app and identifier foundation.want.pass")
    require((info.get("CFBundleShortVersionString"), info.get("CFBundleVersion")) == (version, build),
            "Bundle version/build does not match pubspec.yaml")
    require(info.get("CFBundleExecutable") == "Want Pass", "Unexpected production executable")
    binaries, bundles = code_objects(app)
    expected = [app / "Contents/MacOS/Want Pass"]
    if need_helper:
        expected.append(app / "Contents/Helpers/wpass")
    require(all(path in binaries for path in expected), "Missing production executable or bundled wpass")
    require(any("want_pass_vault.framework" in path.parts for path in binaries), "Missing native vault framework")
    require(any("App.framework" in path.parts for path in binaries), "Missing Flutter AOT framework")
    for binary in binaries:
        architectures = set(run("/usr/bin/lipo", "-archs", binary, capture=True).decode().split())
        require(architectures == ARCHS, f"Expected Universal 2 for {binary.relative_to(app)}, found {sorted(architectures)}")
        if binary in expected:
            for arch in sorted(ARCHS):
                header = run("/usr/bin/otool", "-arch", arch, "-hv", binary, capture=True).decode()
                require(re.search(r"\bEXECUTE\b", header), "Expected an executable Mach-O slice: " + str(binary))
    return binaries, bundles


def sign(path, identity, extra=()):
    run("/usr/bin/codesign", "--force", "--timestamp", "--options", "runtime", "--sign", identity, *extra, path)


def profile_for_app(app, identity):
    team = identity_team(identity)
    profile = app / "Contents/embedded.provisionprofile"
    require(profile.is_file() and not profile.is_symlink(),
            "Touch ID needs a Developer ID provisioning profile for foundation.want.pass. Export a Developer ID archive in Xcode, or set WANT_PASS_DEVELOPER_PROFILE.")
    data = plistlib.loads(run("/usr/bin/security", "cms", "-D", "-i", profile, capture=True))
    entitlement = data.get("Entitlements", {}).get("com.apple.application-identifier", "")
    require(team in data.get("TeamIdentifier", []) and entitlement.startswith(team + ".") and
            fnmatch.fnmatchcase(team + "." + BUNDLE_ID, entitlement),
            "The embedded profile does not authorize this team's production app identifier")
    require(data.get("ExpirationDate") and data["ExpirationDate"].replace(tzinfo=timezone.utc) > datetime.now(timezone.utc)
            and not data.get("ProvisionedDevices") and data.get("ProvisionsAllDevices") is True,
            "A current Developer ID distribution profile is required")
    return data


def signed_entitlements(app, required=True, arch=None):
    architecture = ["--arch", arch] if arch else []
    signed = subprocess.run(["/usr/bin/codesign", "--display", *architecture, "--xml", "--entitlements", "-", str(app)],
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if signed.returncode != 0 or not signed.stdout:
        require(not required, "Cannot read signed entitlements: " + str(app))
        return {}
    return plistlib.loads(signed.stdout)


def expected_entitlements(team):
    required = plistlib.loads((ROOT / "apps/want_pass/macos/Runner/Release.entitlements").read_bytes())
    return {**required, "com.apple.application-identifier": team + "." + BUNDLE_ID}


def distribution_entitlements(app, identity):
    team = identity_team(identity)
    profile_for_app(app, identity)
    required = expected_entitlements(team)
    existing = signed_entitlements(app, required=False)
    expected = team + "." + BUNDLE_ID
    require(not existing.get("com.apple.security.get-task-allow"), "Refusing to distribute debug entitlements")
    require(existing.get("com.apple.application-identifier", expected) == expected, "Existing signature has a different App ID")
    require(not existing.get("keychain-access-groups") or existing["keychain-access-groups"] == [expected],
            "Existing signature includes an unexpected keychain group")
    for key, value in required.items():
        require(key not in existing or existing[key] == value, "Signed entitlement differs from production configuration: " + key)
    return required


def verify_code(app, identity):
    team = identity_team(identity)
    binaries, bundles = inspect_layout(app)
    requirement = f'anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = "{team}"'
    run("/usr/bin/codesign", "--verify", "--deep", "--strict", "--all-architectures", "-R", requirement, app)
    for path in [*binaries, *bundles, app]:
        run("/usr/bin/codesign", "--verify", "--strict", "--all-architectures", "-R", requirement, path)
        for arch in sorted(ARCHS):
            details = subprocess.run(
                ["/usr/bin/codesign", "--display", "--arch", arch, "--verbose=4", str(path)],
                check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
            ).stdout.splitlines()
            require(f"Authority={identity}" in details and f"TeamIdentifier={team}" in details, "Wrong signing identity: " + str(path))
            require(any(line.startswith("Timestamp=") for line in details), "Missing secure timestamp: " + str(path))
            require(any("flags=" in line and re.search(r"\([^)]*\bruntime\b[^)]*\)", line) for line in details),
                    "Hardened runtime missing: " + str(path))
            if path == app / "Contents/Helpers/wpass":
                require(f"Identifier={BUNDLE_ID}.wpass" in details, "Invalid wpass signing identifier")
    required = expected_entitlements(team)
    for arch in sorted(ARCHS):
        require(signed_entitlements(app, arch=arch) == required,
                "Signed production entitlements differ from the release configuration for " + arch)
    profile = profile_for_app(app, identity)
    with tempfile.TemporaryDirectory(prefix="want-pass-cert-") as directory:
        prefix = Path(directory) / "leaf"
        run("/usr/bin/codesign", "--display", f"--extract-certificates={prefix}", app)
        require(Path(str(prefix) + "0").read_bytes() in profile.get("DeveloperCertificates", []),
                "The Developer ID profile does not include the signing certificate")


def publish_file(source, destination):
    # A hard link publishes completely written bytes and refuses replacement.
    os.link(source, destination)


def prepare(app, output, identity):
    identity_team(identity)
    version, _ = release_version()
    name = f"Want-Pass-{version}-macOS-universal.dmg"
    output.mkdir(parents=True, exist_ok=True)
    require(not (output / name).exists(), "Release candidate already exists")
    with tempfile.TemporaryDirectory(prefix="want-pass-prepare-", dir=output) as directory:
        work = Path(directory)
        contents = work / "volume"
        contents.mkdir()
        staged = contents / "Want Pass.app"
        run("/usr/bin/ditto", app, staged)
        inspect_layout(staged, need_helper=False)
        if os.environ.get("WANT_PASS_DEVELOPER_PROFILE"):
            shutil.copyfile(os.environ["WANT_PASS_DEVELOPER_PROFILE"], staged / "Contents/embedded.provisionprofile")
        entitlements = work / "distribution.plist"
        entitlements.write_bytes(plistlib.dumps(distribution_entitlements(staged, identity)))
        helper = staged / "Contents/Helpers/wpass"
        helper.parent.mkdir(exist_ok=True)
        run("/bin/bash", ROOT / "tool/build_wpass.sh", helper, BUNDLE_ID + ".wpass", identity)
        binaries, bundles = inspect_layout(staged)
        for path in binaries:
            if path != helper:
                sign(path, identity)
        for bundle in bundles:
            sign(bundle, identity)
        sign(staged, identity, ("--entitlements", entitlements))
        verify_code(staged, identity)
        (contents / "Applications").symlink_to("/Applications")
        dmg = work / name
        run("/usr/bin/hdiutil", "create", "-srcfolder", contents, "-volname", "Want Pass",
            "-format", "UDZO", "-fs", "HFS+", dmg)
        run("/usr/bin/codesign", "--timestamp", "--sign", identity, dmg)
        run("/usr/bin/hdiutil", "verify", dmg)
        publish_file(dmg, output / name)
    print(output / name)


def receipt_path(image):
    return image.with_suffix(".submission.json")


def write_json(path, data, exclusive=False):
    encoded = (json.dumps(data, indent=2, sort_keys=True) + "\n").encode()
    with tempfile.NamedTemporaryFile(dir=path.parent, prefix=".want-pass-state-", delete=False) as stream:
        temp = Path(stream.name)
        try:
            stream.write(encoded)
            stream.flush()
            os.fsync(stream.fileno())
            if exclusive:
                publish_file(temp, path)
            else:
                temp.replace(path)
        finally:
            temp.unlink(missing_ok=True)


def notarize(image, submission):
    image = image.resolve(strict=True)
    state = receipt_path(image)
    checksum = digest(image)
    if state.exists():
        receipt = json.loads(state.read_text())
        require(receipt.get("sha256") == checksum, "Candidate changed after submission")
        if not receipt.get("id") and not submission:
            raise ValueError("Submission result is unknown. Read notarytool history, then resume with --submission UUID.")
    else:
        receipt = {"sha256": checksum, "file": image.name, "status": "pending"}
        write_json(state, receipt, exclusive=True)
    if submission:
        submission = str(uuid.UUID(submission))
        require(receipt.get("id", submission) == submission, "Receipt identifies another submission")
    elif not receipt.get("id"):
        response = json.loads(run("/usr/bin/xcrun", "notarytool", "submit", image,
                                  "--keychain-profile", PROFILE, "--output-format", "json", capture=True))
        submission = str(uuid.UUID(response["id"]))
    if submission:
        receipt["id"] = submission
        write_json(state, receipt)
    identifier = receipt["id"]
    print("Apple submission", identifier, flush=True)
    result = json.loads(run("/usr/bin/xcrun", "notarytool", "wait", identifier, "--timeout", "30m",
                            "--keychain-profile", PROFILE, "--output-format", "json", capture=True))
    receipt["status"] = result["status"]
    write_json(state, receipt)
    require(receipt["status"] == "Accepted", "Apple did not accept this submission")
    log = json.loads(run("/usr/bin/xcrun", "notarytool", "log", identifier, "--keychain-profile", PROFILE, capture=True))
    require(log.get("sha256", "").lower() == checksum and log.get("status") == "Accepted",
            "Notary log does not match this candidate")
    receipt["verifiedLog"] = True
    write_json(state, receipt)
    print("Accepted. Notary log SHA-256 matches the signed image.")


def verify_image(image, identity):
    team = identity_team(identity)
    require(image.is_file(), "DMG not found")
    run("/usr/bin/hdiutil", "verify", image)
    run("/usr/bin/codesign", "--verify", "--strict", "-R",
        f'anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = "{team}"', image)
    run("/usr/bin/xcrun", "stapler", "validate", image)
    run("/usr/sbin/spctl", "--assess", "--type", "open", "--context", "context:primary-signature", "--verbose=4", image)
    with tempfile.TemporaryDirectory(prefix="want-pass-verify-") as directory:
        mount = Path(directory) / "volume"
        mount.mkdir()
        run("/usr/bin/hdiutil", "attach", "-readonly", "-nobrowse", "-mountpoint", mount, image)
        try:
            app = mount / "Want Pass.app"
            verify_code(app, identity)
            run("/usr/sbin/spctl", "--assess", "--type", "execute", "--verbose=4", app)
        finally:
            run("/usr/bin/hdiutil", "detach", mount)


def finish(image, output, identity):
    receipt = json.loads(receipt_path(image).read_text())
    require(receipt.get("verifiedLog") and receipt.get("status") == "Accepted" and receipt.get("sha256") == digest(image),
            "Expected a verified Apple acceptance receipt for the signed candidate")
    output.parent.mkdir(parents=True, exist_ok=True)
    require(not output.exists() and not output.is_symlink(), "The final release directory must be new")
    with tempfile.TemporaryDirectory(prefix="want-pass-finish-", dir=output.parent) as directory:
        sealed = Path(directory) / "sealed"
        sealed.mkdir()
        copy = sealed / image.name
        shutil.copyfile(image, copy)
        run("/usr/bin/xcrun", "stapler", "staple", copy)
        verify_image(copy, identity)
        sha = digest(copy)
        manifest = sealed / (image.name + ".sha256")
        manifest.write_text(f"{sha}  {image.name}\n")
        os.chmod(copy, 0o444)
        os.chmod(manifest, 0o444)
        sealed.rename(output)
    print(f"{sha}  {output / image.name}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    check = commands.add_parser("inspect")
    check.add_argument("app", type=Path)
    prepare_command = commands.add_parser("prepare")
    prepare_command.add_argument("app", type=Path)
    prepare_command.add_argument("output", type=Path)
    submit = commands.add_parser("notarize")
    submit.add_argument("image", type=Path)
    submit.add_argument("--submission", help="resume a verified existing Apple submission UUID")
    complete = commands.add_parser("finish")
    complete.add_argument("image", type=Path)
    complete.add_argument("output", type=Path)
    verify = commands.add_parser("verify")
    verify.add_argument("image", type=Path)
    args = parser.parse_args()
    identity = os.environ.get("WANT_PASS_DEVELOPER_ID")
    if args.command == "inspect":
        binaries, _ = inspect_layout(args.app)
        print(f"{len(binaries)} Universal 2 Mach-O files in the production app")
    elif args.command == "prepare":
        prepare(args.app, args.output.resolve(), identity)
    elif args.command == "notarize":
        notarize(args.image, args.submission)
    elif args.command == "finish":
        finish(args.image.resolve(), args.output.resolve(), identity)
    elif args.command == "verify":
        verify_image(args.image.resolve(), identity)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
