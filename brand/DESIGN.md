# the-date

Source: existing src/styles/05–10 and components/brand.tsx, 2026-10-18.

Palette: #7451ac #463466 #fff9ed #e45c87 #f4b93c. Typography: Nunito, DM Sans, loaded in app/layout.tsx.

A celebration poster: oversized rounded lettering, violet fields, pink tickets and a playful invitation preview. Preserve the existing confetti mark.

Spacing: 8, 16, 24, 32, 48, 64, 96px. Container: 1200px. Mobile: 24px margins. Decorative illustrations are labeled examples. Icons: components/icon.tsx. Keyboard focus uses background or underline; no outline, ring or focus shadow. Reduced motion respected. No native selects.

Accessible small-text ink: #241638, derived by darkening the existing #463466 violet after the contrast audit on #e45c87. Use it on pink ticket details and encounter cards.

Motion: dedicated entrance of paper layers and a slow rotating floral seal for weddings; animated ticket, response and continuous ribbon for events. Respect system reduced motion automatically. Never add animation pause controls. No emojis or decorative Unicode icons.

Local palette update (2026-11-02): light app surfaces and scaffold use #ffffff. Secondary text uses #625a70; retain the violet accent #7451ac. Keep tinted surfaces for supporting content and retain the system dark theme.
