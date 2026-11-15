# The Date — continuidad de la versión 2.0.0

Fecha: 14 de noviembre de 2026 (America/Lima).

## Alcance y estado

Cambios de código para **iOS y Android**, sobre `origin/main` actualizado mediante `git pull --ff-only`. Base remota: `ef1a5ea`. Se conservaron el workflow manual de iOS y los ajustes de Google Sign-In incorporados por upstream para la compilación 5.

Versión preparada: **2.0.0+6**. Antes de distribuir, comprobar que el número 6 sea superior a todos los builds/versionCodes ya usados en cada tienda.

**Lucas autorizó guardar y subir estos arreglos a GitHub. Este commit incluye el código y los pendientes de la 2.0.0; no se ha subido esa versión a ninguna tienda.** No confundir el código de este repositorio con lo que ya está en TestFlight (1.0.0 build 5).

Lucas indicó continuar aquí únicamente con código: **no compilar, no abrir emuladores ni Waydroid**. Se cerró Android al recibir esa indicación. Antes de esa corrección se habían iniciado pruebas y una compilación Android; esas ejecuciones fueron interrumpidas y no cuentan como validación final. No hay APK, AAB o IPA final entregado de esta versión.

## Qué se cambió

- Apariencia automática `ThemeMode.system`, con temas claro y oscuro completos. No se fuerza el modo claro para ocultar problemas.
- The Date mantiene violeta, rosa, amarillo, tipografía redondeada, ticket recortado, perforaciones y confeti vectorial. Save the Date mantiene serif, papelería superpuesta, reglas finas y sello floral, con un fondo oscuro cálido propio en lugar del violeta compartido.
- Inicio de sesión sin fotografías ni ilustraciones raster decorativas: papel dibujado en Flutter y símbolos SVG. Las fotos reales de perfil, evento y regalos conservan su función de contenido.
- Variante SVG oscura del símbolo de marca; textos, botones, iconos, avatares, filtros y superficies secundarias usan colores del tema. Los botones principales tienen color de texto y fondo coordinados.
- Splash Flutter más breve y sin barra de progreso artificial; conserva la reducción de movimiento del sistema. Splash nativo de iOS con símbolo centrado y color adaptativo; Android con fondos claro/oscuro y configuración de arranque para Android 12+.
- Cuenta → Ayuda y soporte abre HTTPS de la web del producto mediante Safari View Controller / Custom Tabs. Ya no invoca `mailto:`, cuyo manejador en el teléfono podía abrir otra app.
- Cuenta → Eliminar cuenta explica el alcance permanente y abre **https://crea.thedate.now/delete-account**. La web solicita iniciar sesión y confirmar. Abrir ese enlace no borra nada; no se envían solicitudes de soporte desde este botón ni se transmite el token móvil a la URL.
- Cerrar sesión permanece únicamente en Cuenta. No se añadieron emojis, anillos de foco ni controles visibles para pausar animaciones.
- Se actualizaron las pruebas de enlaces/borrado para comprobar el destino, la cancelación, el modo navegador y el manejo de errores; las capturas de revisión admiten apariencia oscura y plataforma iOS/Android.

## Verificación disponible

Sobre la base actualizada: `dart format --output=none --set-exit-if-changed lib test` sin diferencias; `dart analyze lib test` sin incidencias. También se validó la estructura XML/SVG/JSON de los recursos y `git diff --check`. Las suites de ejecución y la revisión visual final deben completarse en casa.

Se verificó HTTP 200 y contenido de soporte/eliminación en ambas webs. El frontend compartido también se actualizó a `42e7db7` para comprobar su implementación de borrado directo. **No se borró ninguna cuenta real.** Esto confirma la disponibilidad de las páginas, no una prueba completa del borrado en producción.

## Pendientes en el PC de casa

### 1. Recuperar y validar el código

- En el PC de casa, clonar este repositorio o actualizar `main` con `git pull --ff-only`. Si hay cambios locales allí, conservarlos e integrarlos antes de continuar. El parche de transferencia previo es una alternativa histórica; no aplicarlo encima de los mismos cambios ya recibidos de GitHub.
- Mantener las credenciales de firma, claves Apple `.p8`, certificados y cuentas de revisión fuera de Git. Recuperarlas desde su ubicación privada existente, sin regenerar identidades de firma.
- Con Flutter compatible con el proyecto, ejecutar desde la raíz del repositorio:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze lib test
flutter test
```

No se volvieron a ejecutar estas pruebas Flutter aquí tras la instrucción de no compilar. No dar por aprobado el resultado solo por el análisis estático.

### 2. Revisar ambos modos y plataformas

En **iPhone real y Android real**, revisar inicio en frío, splash nativo, transición a Flutter, login, Confirmaciones, Regalos, Cuenta, edición de perfil, selección de evento, mensajes de error y estados vacíos. Alternar claro/oscuro con la app abierta y volver desde segundo plano. Validar también orientación, teclado, zona segura y texto ampliado.

Comprobar específicamente:

- La identidad festiva/señorial de cada producto se conserva en oscuro. No hay texto blanco sobre papel claro, cuadros raster claros decorativos ni fondo violeta en la versión oscura de Save the Date.
- El splash de iOS usa realmente el color adaptativo del catálogo de assets y no muestra destellos blancos. Compilar el storyboard y catálogo con el toolchain elegido: aquí solo se revisó su estructura, no se probó el arranque real.
- En Android anterior a 12 y Android 12+, el símbolo del splash no se corta, no queda gigante y los recursos de tema se resuelven correctamente.
- Soporte, Privacidad y Términos abren las páginas del producto sin lanzar inDrive u otra app ajena. Probar dispositivos sin un navegador compatible y confirmar el mensaje de error recuperable.
- El botón de borrado abre la página directa del producto correcto, permite cancelar y exige confirmación final en la web. Probar con **una cuenta desechable autorizada**, nunca con cuentas personales o de clientes.
- Tras borrar la cuenta de prueba en web, volver a la app y comprobar que al refrescar se revoca la sesión y desaparecen los datos privados. Verificar conservación legal/copias de seguridad conforme al texto web; no prometer borrado instantáneo de respaldos.
- Verificar permisos y notificaciones, perfil/foto y login Google en ambos sistemas. La captura original también mostraba un aviso de notificaciones que debe verificarse en dispositivo real.

Capturas de revisión opcionales (generan imágenes desde tests; ejecutar en casa):

```sh
flutter test --dart-define=REVIEW_DARK=true test/visual_review_test.dart
flutter test --dart-define=REVIEW_DARK=true --dart-define=REVIEW_ANDROID=true test/visual_review_test.dart
flutter test test/visual_review_test.dart
flutter test --dart-define=REVIEW_ANDROID=true test/visual_review_test.dart
```

Resultados en `artifacts/visual/ios/` y `artifacts/visual/android/`, separados por `light` y `dark`. Estas capturas Flutter no sustituyen el arranque nativo ni las pruebas en teléfonos reales.

### 3. Compilar y distribuir después de revisar

- Android: compilar **una app por vez**. Abrir y revisar cada app antes de generar el AAB, usando la firma de subida existente. El script del proyecto es `python3 scripts/build_release.py --bundle`; confirmar SDK/JDK y configuración privada antes de ejecutarlo.
- iOS: elegir el toolchain preparado en casa. El workflow `.github/workflows/ios-build.yml` de upstream es manual y genera un **artefacto sin firma**; por sí solo no produce una app instalable mediante TestFlight ni la publica.
- La alternativa Linux `joshuaswarren/omarchy-apple-dev` se clonó en el workspace padre, `work/omarchy-apple-dev`. No se instaló ni ejecutó su toolchain aquí. Faltan preparar SDK/Swift/Flutter compatibles, revisar plugins y recursos iOS (incluido el color dinámico del splash), configurar firma existente y validar el IPA con Apple. No asumir que el clon es un entorno listo para compilar.
- Revisar el build iOS final, firmas, entitlements, Firebase, Google callback y privacidad; subir a TestFlight y probar la **2.0.0**, no reutilizar las pruebas del build 5.
- La cuenta `lucas.santillan.arevalo@gmail.com` ya fue invitada al grupo interno QA de ambas apps; verificar que reciba el nuevo build.
- Grabar los videos en los teléfonos una vez aprobada la apariencia. En la consulta previa ambas apps estaban pendientes de revisión desde el 13/11/2026 y no se encontró una solicitud de video: comprobar de nuevo los mensajes reales de Apple antes de responder o adjuntar material. Las capturas no prueban el motivo de una demora/rechazo.
- Preparar capturas y ficha 2.0.0, revisar las declaraciones de privacidad y acceso del revisor; solo después gestionar los envíos de Apple/Google. No retirar el envío 1.0.0 actual hasta tener la nueva versión validada y decidir el reemplazo.

## Archivos principales

`lib/ui/theme.dart`, `lib/ui/widgets/brand.dart`, `lib/ui/login.dart`, `lib/ui/startup_splash.dart`, `lib/ui/account.dart`, `lib/ui/app.dart`, `lib/app_config.dart`, `pubspec.yaml`, `assets/brand/mark-dark.svg`, recursos Android de arranque y `ios/Runner/Assets.xcassets/LaunchBackground.colorset`/`Base.lproj/LaunchScreen.storyboard`.

## Segunda revisión por código — 14/11/2026

Se revisaron de nuevo las pantallas frente a los problemas de las capturas, sin abrir la app ni compilarla. Se corrigieron además:

- El papel del inicio y el ticket del evento tienen un tono de marca separado del fondo de las tarjetas, también en oscuro. Las perforaciones cambian con el tema y reservan espacio para no pasar sobre el título o el selector.
- La flecha de «Continuar en la web» usa `onPrimary`, evitando el icono blanco sobre el botón claro del modo oscuro.
- El encabezado define su alineación por marca (The Date a la izquierda, Save the Date centrado), idéntica en iOS y Android, sin depender del valor predeterminado de la plataforma. Los iconos de las barras del sistema se adaptan al modo.
- Los diálogos usan tipografía y superficies de la marca. Los avisos flotantes usan texto y fondo coordinados en lugar de heredar combinaciones de colores ajenas.
- El splash nativo incluye símbolo claro/oscuro en iOS a 1x, 2x y 3x y recursos nocturnos Android. En Android anterior a 12, el símbolo usa 88dp con densidades específicas; Android 12+ mantiene su recurso con margen para la máscara del sistema. Son recursos fuente generados, no una compilación de la app.
- El splash Flutter puede desplazarse si falta altura o aumenta el texto, en vez de desbordarse.
- Privacidad y Condiciones en el login usan el mismo abridor HTTPS y manejo recuperable de errores que Cuenta; no quedan llamadas de apertura sin capturar excepciones en esos enlaces.
- El selector personalizado de eventos incorpora flechas arriba/abajo y mantiene Tab, Escape y cierre exterior propios de la ruta modal. Probarlo con teclado físico en casa.
- Los teclados de login, búsqueda y edición de perfil solicitan la apariencia del tema; correo y contraseña desactivan autocorrección y sugerencias.

Verificación final de esta revisión: formato Dart sin diferencias; `dart analyze lib test` sin incidencias en ambos repositorios; `git diff --check` sin errores; estructura XML/JSON de los recursos comprobada. Se calculó el contraste de las combinaciones de texto/acciones y superficies revisadas: mínimos 5,46:1 (The Date claro), 7,22:1 (The Date oscuro), 5,27:1 (Save the Date claro) y 7,08:1 (Save the Date oscuro). No son mediciones de una pantalla renderizada ni incluyen controles deshabilitados, fotografías o elementos puramente decorativos. Las pruebas de contraste existentes se ampliaron para incluir el papel de invitación y el color de error, pero no se ejecutaron aquí las suites Flutter.

Para regenerar los PNG de arranque desde los SVG, ejecutar en casa, desde cada repositorio:

```sh
npm --prefix scripts ci
node scripts/generate_splash.cjs
```

Pendiente especialmente: revisar la máscara y tamaño real del splash Android en ambas generaciones, la variante nocturna del catálogo iOS, estado de barras del sistema al entrar/salir del navegador y recuperación de sesión al volver de eliminar la cuenta. Confirmar que teclado/texto ampliado no recortan botones o títulos. Ninguna de estas pruebas de dispositivo se declara completada por el análisis estático.
