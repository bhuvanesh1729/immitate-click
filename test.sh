#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/module-cache
SWIFTC="$(xcrun --find swiftc)"
"$SWIFTC" -sdk "$(xcrun --show-sdk-path)" -target arm64-apple-macosx13.0 -module-cache-path "$PWD/build/module-cache" Sources/KeepAwakeController.swift Tests/main.swift -o build/lifecycle-tests
./build/lifecycle-tests
