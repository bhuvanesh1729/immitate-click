# immitate click

A small native macOS window with Start, Stop, and an Active/Inactive status.
It uses Apple's `/usr/bin/caffeinate` to prevent system and display **idle sleep**.
It does not generate clicks, move the mouse, or simulate user activity.

## Download

Get the Apple silicon DMG and `SHA256SUMS.txt` from
[GitHub Releases](https://github.com/bhuvanesh1729/immitate-click/releases).
Requires macOS 13 or later. This build is ad-hoc signed and is not Developer ID
signed or notarized by Apple; macOS may restrict opening a downloaded copy.

## Build and run

Requires Apple silicon, macOS 13+, and Xcode or the Command Line Tools to build.

```sh
bash test.sh
bash build.sh
open "build/immitate click.app"
```

The app opens inactive. Start begins keep-awake; Stop ends it. Closing the window
or choosing **immitate click → Quit immitate click** (Command-Q) also ends it.
No installation, login item, helper, Accessibility permission, or external dependency
is needed. The bundle is locally ad-hoc signed, not Developer ID signed or notarized
for distribution to other computers.

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

After building, run `bash package-dmg.sh` to create
`build/immitate-click-1.0.0-arm64.dmg`. The image contains only the tested app,
an Applications shortcut, and brief usage notes. Packaging verifies the app's
signature and the disk image's integrity; it does not install, launch, or upload
anything. Downloaded copies may be restricted by macOS because this build is
ad-hoc signed and has no Developer ID signature or Apple notarization.

Generated artifacts and local verification notes are excluded from Git.
Release binaries are provided separately through GitHub Releases.

## License

No open-source license is included.
