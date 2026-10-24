#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="$PWD/build/immitate click.app"
DMG="$PWD/build/immitate-click-1.0.0-arm64.dmg"
test -d "$APP"
/usr/bin/codesign --verify --strict "$APP"
STAGING="$(mktemp -d "$PWD/build/dmg-staging.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
chmod 755 "$STAGING"
/usr/bin/ditto --noextattr --noqtn "$APP" "$STAGING/immitate click.app"
ln -s /Applications "$STAGING/Applications"
cat > "$STAGING/Read Me.txt" <<'EOF'
immitate click 1.0.0
Apple silicon Mac, macOS 13 or later

Drag immitate click.app to Applications if you choose to install it.
Open the app and click Start to keep the Mac and display awake.
Click Stop, close the window, or quit to end keep-awake.

Automatic lock and password policies still apply. No clicks or mouse
movement are simulated. No startup items or helpers are installed.

This is a locally ad-hoc signed build. It is not Developer ID signed
or notarized by Apple. macOS may restrict opening a downloaded copy.
EOF
/usr/bin/hdiutil create -ov -format UDZO -fs HFS+ -volname "immitate click" \
    -nospotlight -anyowners -srcowners off -srcfolder "$STAGING" "$DMG"
/usr/bin/hdiutil verify "$DMG"
/usr/bin/shasum -a 256 "$DMG"
echo "Packaged $DMG"
