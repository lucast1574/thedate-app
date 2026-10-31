# The Date para Android

App Flutter independiente con tres destinos: **Confirmaciones**, **Regalos** y **Cuenta**. Consulta el mismo evento y los mismos permisos del estudio web. No incluye el editor, compras ni envíos de invitaciones.

## Desarrollo

Flutter 3.44.5 / Dart 3.12.2, Android SDK 36 y Java 17.

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d DISPOSITIVO
```

Usar Android (scrcpy)/Waydroid para la vista nativa. No iniciar emuladores AVD. Compilar una app por vez. Android: `now.thedate.app`, minSdk 24, targetSdk 36. iOS queda fuera del alcance de esta versión.

API exclusiva: `https://api.thedate.now/products/general`. No cambiar al otro producto como respaldo. Sesión cifrada en el almacenamiento seguro de Android; nunca se guarda la contraseña. Al cerrar sesión se borra el token local. La sesión del backend vence y exige volver a entrar.

Los datos se consultan al abrir, al volver a primer plano, al deslizar y cada 45 segundos mientras la app está activa. Un error conserva el último snapshot con su fecha de actualización. No hay notificaciones push, publicidad ni analítica publicitaria.

## Firebase y firma

El archivo `android/app/google-services.json` contiene configuración pública de cliente; no contiene credenciales administrativas. Las huellas debug y release se documentan en `store/signing-fingerprints.json`. Las claves de subida y sus contraseñas permanecen fuera del repositorio, en `~/.local/share/thedate-mobile/`. No regenerar una clave existente al actualizar la app.

```sh
python3 scripts/build_release.py          # APK firmado
python3 scripts/build_release.py --bundle # AAB firmado
```

El script requiere el archivo privado `thedate-app-signing.json` de esa carpeta. El build release nunca utiliza la firma debug. Después de habilitar Play App Signing hay que registrar también en Firebase la huella del certificado de distribución de Google Play.

## Iconos y ficha

Los iconos se derivan del vector oficial; no se redibuja el símbolo. Recursos de tienda en `store/es-419/`. Herramienta de generación: Sharp e ImageMagick; launcher: flutter_launcher_icons.

```sh
npm --prefix scripts ci
node scripts/generate_assets.cjs
dart run flutter_launcher_icons
```

## Acceso de revisión y privacidad

Las credenciales de revisión son de una cuenta normal, aislada de usuarios reales, guardadas fuera del repositorio. No existe un bypass de autenticación en la app. `integration_test/preview.dart` es una entrada exclusivamente local para previsualizar datos ficticios y no se utiliza al compilar release.

Cuenta permite solicitar la eliminación mediante el sistema autenticado de soporte con una clave idempotente. No afirma que la cuenta se borre de inmediato. Las páginas `/privacidad`, `/terminos` y `/eliminar-cuenta` viven en la landing del producto. Soporte: lucasraulsantillanarevalo@gmail.com.
