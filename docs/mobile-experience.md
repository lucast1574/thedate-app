# Mobile experience

The mobile app is for the person celebrating and the couple, using their normal account. It has three destinations: confirmations, gifts and account. No editor, shopping or planner dashboard.

The existing organization-scope API is a personal-access query: the backend filters ownerId or coupleUserIds. It does not require a planner role. Existing paid/non-demo product boundaries remain in effect.

One event is displayed as context without a dropdown arrow or tap action. With several accessible events, the top selector opens the same themed bottom sheet from every destination. Choosing an event clears the previous snapshot; list filters are keyed by event ID. Arbitrary event IDs are rejected locally and access is checked by the backend.

Android system back dismisses the active route or modal first. From Gifts or Account, back returns to Confirmations. At the root, normal system exit behavior is preserved. Flutter routes and modal sheets retain native platform dismissal, safe areas and keyboard handling. Navigation tests run with Android and iOS platform variants. No custom swipe recognizers override system gestures.

Launcher icons are generated from the existing official brand assets for Android adaptive, monochrome and legacy launchers and iOS. Run dart run flutter_launcher_icons to regenerate. UI screenshots are rendered from Flutter widgets with sample data by test/visual_review_test.dart; they are not screenshots of a physical device.

Validation: flutter analyze, flutter test, Dart format and Android debug APK builds. Physical Android/iPhone navigation and signed iOS runtime validation remain pending.

## Reference design and startup

The mobile reference images guide login, confirmations, gifts and account. The Date uses lavender, heavy Nunito headings, pink punctuation, ticket event context and rounded cards. Save the Date uses ivory, Cormorant headings, terracotta, double rules and divided rows. Official vector marks are retained; login artwork is a generated raster asset.

The animated startup mark runs while session and data initialization begin. Entry waits for initialization and the finite introduction; reduced motion skips the movement. Firebase initializes after runApp so startup remains visible.

The normal entry point lib/main.dart uses the real product repository. integration_test/preview.dart is debug-only, visibly marked DATOS DE EJEMPLO and isolated from lib. Preview gift photography and guest names do not supply fallback data to real accounts. Normal avatars, totals, response dates and event photos come from the backend; missing images use a brand or gift placeholder.

Android emulator rendering was inspected for both apps. The latest validation passed 28 tests per app, analysis, formatting and connected/preview debug APK builds. iOS platform navigation is covered by widget tests; iPhone runtime validation is still pending.

## Backend completion

Normal lib/main.dart initializes the real product repository and a notification gateway. Account enables notification permission; existing grants synchronize automatically after login/resume. A notification refreshes authorized events before selecting its event and tab. Foreground messages refresh data. Logout unregisters the device in FCM and the API before clearing the stored session. API timeouts are translated into a retryable connection message. When access to an event disappears, its previous data and update timestamp are cleared. Gift photographs use the authenticated backend proxy instead of a vendor image URL.

## Google identity and profile photo

Google login is independent of Firebase Messaging initialization. A successful ID token is returned directly to the product API without clearing Google credential state in a finally block. Native sign-out is performed on logout with bounded, nonblocking cleanup. Provider errors use user-facing messages without logging identity tokens or profile data.

The account model reads googlePhotoUrl and avatarVersion from both login and session restoration. The profile avatar follows web precedence: authenticated custom profile photo, then HTTPS Google photo, then initials. Google image requests never include the API bearer token. Custom-photo cache URLs include account ID and version to prevent images being reused across different users.

## Starting on the web

An authenticated account with no accessible active invitation sees a branded explanation and Continue on the web button on Confirmations and Gifts. It opens only AppConfig.website in an external browser; no API session token is added to the URL. The message explains web creation/purchase and the email used for couple/member access. Loading and API failures do not show the no-invitation prompt. Accounts with an existing accessible invitation keep their normal event screens.

## Minimal profile editing

The pencil in Account opens a branded bottom sheet with only the visible name and gallery photo. Draft changes are saved explicitly through the existing product profile and avatar API; closing the sheet discards unsaved changes. Photos are resized to 480 pixels and re-encoded without source metadata before upload. Successful custom photos take precedence over the Google photo. Logout remains only in Account, centered inside a softly colored rounded button with page margins.

Validation: 32 tests per app and clean analysis. Android emulator inspection covers both branded editors, automatic Google photos, rounded logout buttons and native back dismissal; iPhone runtime validation remains pending.

## Event date and general invitation

Event headers keep the event-local date and add a calendar-day countdown using the backend IANA timeZone. Today, tomorrow and past celebrations have explicit labels; missing dates hide the countdown. A published event with a validated slug exposes Ver mi invitación, opening only its product invitation HTTPS root in the external browser. No guest identifier, personal invitation token, session or query is included. Unpublished invitations display a noninteractive publication status.

Navigation consumes push destinations once; manual tab changes cancel pending push navigation so a delayed refresh cannot override them. Empty Confirmations and Gifts have distinct copy and SVG icons. Save the Date addresses each signed-in person individually with tu rather than vuestra/vuestro. Validation: clean analysis and 38 tests per app, including event-zone/DST dates, generic URLs, narrow-screen layout, rapid navigation during refresh and notification/manual-selection races.

## Gift list typography and spacing

Product titles use DM Sans at medium weight, capped at two lines. Consistent square white image wells contain the complete product photo. Reservation/received status and the reserving person appear below the title; no trailing status column competes for width. Wedding keeps ivory paper and fine separators; general keeps rounded cards and its violet brand. The decorative list footer is removed.


## Consulta de eventos anteriores

El cierre se calcula al terminar el día local del evento, con la misma zona IANA del backend y fallback UTC. Al restaurar sesión no se selecciona automáticamente un evento anterior; el usuario puede elegirlo aunque sea el único. Una selección explícita se conserva al refrescar. Las notificaciones abren el evento indicado y la sección correspondiente; los identificadores que ya no existen se ignoran.

Confirmaciones, Regalos y Cuenta siguen siendo los tres destinos principales. Un evento anterior usa listas de consulta con la tipografía y colores del tema de cada app. Mesas se consulta en un panel nativo mediante GET autenticado, sin edición. El enlace de invitación abre la copia privada del estudio para consultar y descargar; usa únicamente el ID y una pestaña, nunca un token de sesión. La sesión del navegador es independiente y puede requerir inicio de sesión. El enlace público apagado no se usa para eventos anteriores.

Los registros anteriores no hacen polling cada 45 segundos. Se mantienen el refresco manual y al regresar del segundo plano. No se añaden avisos comerciales o mensajes sobre la regla de cierre.
