from datetime import datetime, timedelta
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import macos_release as release


class MacReleaseTests(unittest.TestCase):
    @unittest.skipUnless(sys.platform == "darwin", "requires macOS codesign")
    def test_reads_xml_entitlements_from_public_system_binary(self):
        entitlements = release.signed_entitlements(Path("/usr/bin/codesign"))
        self.assertIsInstance(entitlements, dict)
        self.assertTrue(entitlements)

    def test_identity_is_developer_id_application(self):
        self.assertEqual(release.identity_team("Developer ID Application: Example (EXAMPLE123)"), "EXAMPLE123")
        for identity in ("-", "Apple Development: Example (EXAMPLE123)", "", None):
            with self.assertRaises(ValueError):
                release.identity_team(identity)

    def test_signs_only_release_entitlements_even_if_the_input_has_extra_permissions(self):
        identity = "Developer ID Application: Example (EXAMPLE123)"
        app_id = "EXAMPLE123.foundation.want.pass"
        imported = {
            "com.apple.application-identifier": app_id,
            "com.apple.security.app-sandbox": True,
            "com.apple.security.cs.disable-library-validation": True,
        }
        with mock.patch.object(release, "profile_for_app"), mock.patch.object(
            release, "signed_entitlements", return_value=imported
        ):
            self.assertEqual(release.distribution_entitlements(Path("fixture.app"), identity), {
                "com.apple.application-identifier": app_id,
                "com.apple.security.app-sandbox": True,
                "com.apple.security.files.user-selected.read-write": True,
            })
            imported["com.apple.security.get-task-allow"] = True
            with self.assertRaisesRegex(ValueError, "debug entitlements"):
                release.distribution_entitlements(Path("fixture.app"), identity)

    def test_notary_receipt_survives_an_ambiguous_submission(self):
        with tempfile.TemporaryDirectory() as temp:
            image = Path(temp) / "fixture.dmg"
            image.write_bytes(b"release fixture")
            with mock.patch.object(release, "run", side_effect=OSError("interrupted")) as invoke:
                with self.assertRaises(OSError):
                    release.notarize(image, None)
                with self.assertRaisesRegex(ValueError, "unknown"):
                    release.notarize(image, None)
                self.assertEqual(invoke.call_count, 1)
            image.write_bytes(b"changed fixture")
            with self.assertRaisesRegex(ValueError, "changed"):
                release.notarize(image, "12345678-1234-1234-1234-123456789012")

    def test_publication_is_exclusive(self):
        with tempfile.TemporaryDirectory() as temp:
            original, final = Path(temp) / "original", Path(temp) / "final"
            original.write_bytes(b"candidate")
            release.publish_file(original, final)
            alternate = Path(temp) / "other"
            alternate.write_bytes(b"other")
            with self.assertRaises(FileExistsError):
                release.publish_file(alternate, final)
            self.assertEqual(final.read_bytes(), b"candidate")

    def test_profile_must_authorize_the_production_app_and_current_team(self):
        identity = "Developer ID Application: Example (EXAMPLE123)"
        with tempfile.TemporaryDirectory() as temp:
            app = Path(temp) / "Want Pass.app"
            contents = app / "Contents"
            contents.mkdir(parents=True)
            (contents / "embedded.provisionprofile").write_bytes(b"fixture")
            profile = {
                "Entitlements": {"com.apple.application-identifier": "EXAMPLE123.foundation.want.pass"},
                "ProvisionsAllDevices": True, "TeamIdentifier": ["EXAMPLE123"],
                "ExpirationDate": datetime.utcnow() + timedelta(days=1),
            }
            with mock.patch.object(release, "run", return_value=plistlib.dumps(profile)):
                self.assertEqual(release.profile_for_app(app, identity)["TeamIdentifier"], ["EXAMPLE123"])
            profile["Entitlements"]["com.apple.application-identifier"] += ".dev"
            with mock.patch.object(release, "run", return_value=plistlib.dumps(profile)):
                with self.assertRaisesRegex(ValueError, "production app"):
                    release.profile_for_app(app, identity)

    @unittest.skipUnless(sys.platform == "darwin", "requires macOS Mach-O tooling")
    def test_inspects_actual_universal_and_thin_nested_code_without_signing(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            app = root / "Want Pass.app"
            contents = app / "Contents"
            main = contents / "MacOS/Want Pass"
            helper = contents / "Helpers/wpass"
            vault = contents / "Frameworks/want_pass_vault.framework/want_pass_vault"
            flutter = contents / "Frameworks/App.framework/App"
            for path in (main, helper, vault, flutter):
                path.parent.mkdir(parents=True)
            version, build = release.release_version()
            (contents / "Info.plist").write_bytes(plistlib.dumps({
                "CFBundleIdentifier": release.BUNDLE_ID, "CFBundleExecutable": "Want Pass",
                "CFBundleShortVersionString": version, "CFBundleVersion": build,
            }))
            source = root / "fixture.c"
            source.write_text("int main(void) { return 0; }\n")
            slices = []
            for arch in sorted(release.ARCHS):
                binary = root / arch
                subprocess.run(["/usr/bin/xcrun", "--sdk", "macosx", "clang", "-arch", arch, "-mmacosx-version-min=12.0",
                                "-Wl,-no_adhoc_codesign", source, "-o", binary], check=True)
                slices.append(binary)
            subprocess.run(["/usr/bin/lipo", "-create", *slices, "-output", main], check=True)
            for path in (helper, vault, flutter):
                shutil.copyfile(main, path)
            binaries, _ = release.inspect_layout(app)
            self.assertEqual(len(binaries), 4)
            shutil.copyfile(slices[0], vault)
            with self.assertRaisesRegex(ValueError, "Universal 2"):
                release.inspect_layout(app)
            shutil.copyfile(main, vault)
            link = contents / "external"
            link.symlink_to(root)
            with self.assertRaisesRegex(ValueError, "leaves"):
                release.inspect_layout(app)
            link.unlink()
            doc = plistlib.loads((contents / "Info.plist").read_bytes())
            doc["CFBundleIdentifier"] += ".dev"
            (contents / "Info.plist").write_bytes(plistlib.dumps(doc))
            with self.assertRaisesRegex(ValueError, "production"):
                release.inspect_layout(app)


if __name__ == "__main__":
    unittest.main()
