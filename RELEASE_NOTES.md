# immitate click 1.0.1

Repairs distribution signing: Developer ID signature, hardened runtime, secure
timestamp, and Apple notarization with stapled tickets. Replaces the original
ad-hoc distribution; v1.0.0 remains available for historical reference.

Includes a minimal Xcode project and shared scheme for Archive and Organizer
distribution, using the existing source files without behavior changes.

Minimal native macOS app with Start, Stop, and Active/Inactive status.

- Start requests display and system idle-sleep prevention using Apple's caffeinate.
- Stop, closing the window, and quitting end the session.
- No clicks, cursor movement, startup items, helpers, or new permissions.
- Automatic lock and password policies still apply.

## Requirements and download

Apple silicon Mac running macOS 13 or later. Download
`immitate-click-1.0.1-arm64.dmg` and verify it using the accompanying
`SHA256SUMS.txt`. The DMG contains the app, an Applications shortcut, and brief
usage notes.

This release is Developer ID signed and notarized by Apple. Standard macOS
security checks and organization policies still apply. Notarization does not
imply an App Store review or an endorsement by Apple.

## Verification

The app builds successfully, and five real-process lifecycle tests cover
Start/Stop idempotence, launch failure, unexpected exit, cleanup, and abrupt
parent-exit cleanup. Approved GUI checks verified Start → Stop and Start → Quit,
with both expected assertions present while active and released afterward.
The release DMG passed checksum verification, read-only mounting, content checks,
and app signature verification. No managed-lock prevention claim is made.
