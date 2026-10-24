#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="$PWD/build/immitate click.app"
mkdir -p "$APP/Contents/MacOS" build/module-cache
SWIFTC="$(xcrun --find swiftc)"
"$SWIFTC" -sdk "$(xcrun --show-sdk-path)" -target arm64-apple-macosx13.0 \
    -module-cache-path "$PWD/build/module-cache" -O -framework Cocoa \
    Sources/KeepAwakeController.swift Sources/main.swift -o "$APP/Contents/MacOS/immitate click"
cp Info.plist "$APP/Contents/Info.plist"
/usr/bin/plutil -lint "$APP/Contents/Info.plist"
/usr/bin/codesign --force --sign - --identifier local.immitate-click "$APP"
/usr/bin/codesign --verify --strict "$APP"
echo "Built $APP"
