# immitate click

A small native macOS window with Start, Stop, and an Active/Inactive status.
It uses Apple's `/usr/bin/caffeinate` to prevent system and display **idle sleep**.
It does not generate clicks, move the mouse, or simulate user activity.

## Download

Get the Apple silicon DMG and `SHA256SUMS.txt` from
[GitHub Releases](https://github.com/bhuvanesh1729/immitate-click/releases).
Requires macOS 13 or later. Default local builds are ad-hoc signed. Published
v1.0.1 artifacts require Developer ID signing and Apple notarization. The original
v1.0.0 release was ad-hoc signed and may be restricted by macOS.

## Build and run

Requires Apple silicon, macOS 13+, and Xcode or the Command Line Tools to build.

```sh
bash test.sh
bash build.sh
open "build/immitate click.app"
```

The app opens inactive. Start begins keep-awake; Stop ends it. Closing the window
or choosing **immitate click → Quit immitate click** (Command-Q) also ends it.
No login item, helper, Accessibility permission, or external dependency is needed.
The default local build is ad-hoc signed. For distribution, provide an existing
Developer ID Application identity using `SIGNING_IDENTITY`; the build enables
hardened runtime and a secure signing timestamp.

## Limits

Managed screen-lock and password policies still apply. This app does not change
those settings or promise to prevent a managed lock. It does not prevent explicit
sleep, closing the lid, shutdown, or force-unlock a locked screen.

The child command is `caffeinate -di -w <app PID>`. Stop and normal quit terminate
it; the watched PID releases assertions if the app exits abruptly. The status
reflects the child process, not a guarantee that macOS has honored every request.

`test.sh` runs short real-process tests, reads `pmset -g assertions`, and cleans up
its own processes. It does not change authentication or profile settings.

## Local DMG

### Xcode Organizer

Open `immitate click.xcodeproj`, select the shared `immitate click` scheme, and
choose Product → Archive. Release builds use the existing Developer ID Application
identity for the configured personal team, hardened runtime, and a secure timestamp.
In Organizer choose Distribute App → Developer ID → Upload (or the corresponding
Direct Distribution workflow in newer Xcode versions). Review the team, certificate,
and entitlements before upload. Wait for Apple to report Ready to distribute, then
choose Export Notarized App and validate its stapled ticket before packaging.
Copy that exported app bundle to `build/immitate click.app`, replacing the local
build there, because `package-dmg.sh` reads that exact path.
This uses the signed-in Xcode account; Apple may request reauthentication.

Organizer requires an app archive and does not submit an arbitrary custom DMG.
The final DMG still needs its own notarization/stapling checks before publication.
The existing lifecycle tests remain available through `bash test.sh`.

### Command-line alternative

Distribution uses a Developer ID Application identity and an existing secure
Keychain notarization profile. Never put a password or private key in this repo.

```sh
export SIGNING_IDENTITY='YOUR_DEVELOPER_ID_APPLICATION_IDENTITY'
export NOTARY_PROFILE='YOUR_KEYCHAIN_NOTARIZATION_PROFILE'
bash build.sh
ditto -c -k --keepParent "build/immitate click.app" build/notarization.zip
xcrun notarytool submit build/notarization.zip --keychain-profile "$NOTARY_PROFILE" --wait
# Continue only when Apple reports Accepted.
xcrun stapler staple "build/immitate click.app"
xcrun stapler validate "build/immitate click.app"
bash package-dmg.sh
xcrun notarytool submit build/immitate-click-1.0.1-arm64.dmg --keychain-profile "$NOTARY_PROFILE" --wait
# Continue only when Apple reports Accepted.
xcrun stapler staple build/immitate-click-1.0.1-arm64.dmg
xcrun stapler validate build/immitate-click-1.0.1-arm64.dmg
```

Packaging refuses an app without Developer ID signing, hardened runtime, and a
valid stapled notarization ticket. The image contains only the app, an Applications
shortcut, and brief usage notes. Packaging verifies the app's signature and the
disk image's integrity; it does not install or launch anything. Before publication,
verify Gatekeeper assessment, mount the image read-only to check its contents,
unmount it, and generate the final SHA-256 checksum after stapling.

Generated artifacts and local verification notes are excluded from Git.
Release binaries are provided separately through GitHub Releases.

## License

No open-source license is included.
