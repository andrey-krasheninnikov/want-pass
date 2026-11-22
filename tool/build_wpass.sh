#!/bin/sh
set -eu

[ "$#" = 3 ] || { echo 'usage: build_wpass.sh OUTPUT IDENTIFIER SIGNING_IDENTITY' >&2; exit 2; }
output=$1
identifier=$2
identity=$3
case "$identifier" in
    foundation.want.pass.wpass|foundation.want.pass.dev.wpass) ;;
    *) exit 2 ;;
esac
repo=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/want-pass-wpass.XXXXXX")
trap 'rm -rf -- "$work"' EXIT HUP INT TERM
mkdir -p "$(dirname -- "$output")"
for arch in arm64 x86_64; do
    /usr/bin/xcrun --sdk macosx swiftc -O -target "$arch-apple-macos12.0" -framework Security \
        "$repo/apps/want_pass/macos/Shared/LocalToolsTransport.swift" \
        "$repo/apps/want_pass/macos/wpass/SSHConfiguration.swift" \
        "$repo/apps/want_pass/macos/wpass/main.swift" -o "$work/$arch"
done
/usr/bin/lipo -create "$work/arm64" "$work/x86_64" -output "$work/wpass"
if [ "$identity" = "-" ]; then
    /usr/bin/codesign --force --sign - --identifier "$identifier" --options runtime "$work/wpass"
else
    /usr/bin/codesign --force --sign "$identity" --timestamp --identifier "$identifier" --options runtime "$work/wpass"
fi
/usr/bin/codesign --verify --strict "$work/wpass"
install -m 0755 "$work/wpass" "$output"
