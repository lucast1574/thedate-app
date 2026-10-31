# Mobile app

Android Flutter app. Keep exactly three main destinations: Confirmaciones, Regalos, Cuenta. Do not add the web editor, purchases or complex management flows. Use only the configured product API; never fall back to another product.

Respect brand/DESIGN.md and brand/VOICE.md. Reuse the SVG icon system. No emojis, focus rings or focus outlines. Logout exists only in Cuenta. Keep secrets, signing keys and reviewer credentials outside Git. No demo access bypass in release builds.

Validate dart format, flutter analyze and flutter test. Preview with Android (scrcpy)/Waydroid, never launch an AVD. Compile only one Android build at a time. Before AAB generation open the app for the user.
