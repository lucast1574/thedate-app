# Firebase mobile configuration

Verified on 2026-11-01. Product: The Date.

- Firebase project: `the-date-5c49a`.
- Android application ID and iOS bundle ID: `now.thedate.app`.
- Apple team: `9BZKHZM3ZB`; bundle registered with Push Notifications.
- Google provider enabled. Android OAuth clients cover the Windows debug key, the Windows upload key, and the previously registered keys.
- iOS Google client and reversed URL scheme are configured in `ios/Runner/Info.plist`. The backend server client is deliberately the existing product web OAuth client.
- FCM HTTP v1 enabled. APNs development key `8LJ4S49625` and production key `57T86UXKLQ` uploaded to this project's iOS app, each restricted to this bundle and its environment.
- Debug iOS uses development APNs entitlement; Release/Profile use production. Remote notifications background mode is enabled.

## Android upload signing from this PC

Run `python scripts/build_release.py --verify-only` to verify the private key against `store/signing-fingerprints.json`. Run `python scripts/build_release.py` for a signed APK, or add `--bundle` for an AAB. Open the app for the user before AAB generation, per AGENTS.md.

Windows uses `%USERPROFILE%/.codex/secrets/thedate-app-release.jks` and `thedate-app-android-signing.dpapi`. The password metadata is DPAPI encrypted for the Windows account. These files stay outside Git. Linux uses the existing private `~/.local/share/thedate-mobile/thedate-app-signing.json` contract; it must reference the same upload certificate documented in the repo. Never generate a replacement implicitly.

`legacyUpload` is a historical fingerprint whose private key was not found locally. The new Windows upload key was explicitly authorized before the first Play upload. Existing Firebase hashes were retained.

Google Play App Signing is pending: this app is not yet registered in the inspected Play Console account. Once Play creates the distribution certificate, add its SHA-1/SHA-256 to Firebase as well. The upload certificate alone does not cover Play-distributed installations.

## Notification scope

The normal app registers Firebase Installation IDs through POST /devices after an authenticated login/resume when permission is already granted. Account offers deliberate permission activation. Logout unregisters with FCM and removes the API registration. Tapping a notification reloads authorized events before selecting the requested event/tab; Android foreground messages refresh data without a separate banner, while iOS uses foreground OS presentation.

The backend worker reads canonical response/reservation timestamps, rechecks current access and claims each notification in MongoDB before sending through FCM HTTP v1. Each product has a dedicated sender with the Firebase Cloud Messaging API Admin role, stored encrypted outside Git and injected into its backend environment. validate_only confirmed both senders authenticate (a deliberately nonexistent FID returns UNREGISTERED). Google login has now completed against the real backend in both Android emulators after user account selection. Actual push delivery and iOS login remain unverified.

## Validation limits

iOS project files are present, but there is no signed iOS build/profile or device test yet. Follow the established SheepLink Linux iOS toolchain (`joshuaswarren/omarchy-apple-dev`, installed at `/home/server/codex-tests/sheeplink-ios/toolchain` on the NUC) when preparing that build; never mix application identifiers or Firebase projects.
