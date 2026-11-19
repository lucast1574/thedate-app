import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @m000.
  ///
  /// In es, this message translates to:
  /// **'Abriendo la web…'**
  String get m000;

  /// Abriendo {v0}
  ///
  /// In es, this message translates to:
  /// **'Abriendo {v0}'**
  String m001(String v0);

  /// No description provided for @m002.
  ///
  /// In es, this message translates to:
  /// **'Abriendo…'**
  String get m002;

  /// No description provided for @m003.
  ///
  /// In es, this message translates to:
  /// **'Abriremos la web de Save the Date. Inicia sesión con la cuenta que quieres eliminar y confirma allí el borrado. Es permanente: se eliminarán tu perfil, tus eventos, invitados y archivos de este producto. No elimina tu cuenta del otro producto ni tu cuenta de Google. Abrir la web todavía no borra nada.'**
  String get m003;

  /// No description provided for @m004.
  ///
  /// In es, this message translates to:
  /// **'Abriremos la web de The Date. Inicia sesión con la cuenta que quieres eliminar y confirma allí el borrado. Es permanente: se eliminarán tu perfil, tus eventos, invitados y archivos de este producto. No elimina tu cuenta del otro producto ni tu cuenta de Google. Abrir la web todavía no borra nada.'**
  String get m004;

  /// No description provided for @m005.
  ///
  /// In es, this message translates to:
  /// **'Activando notificaciones…'**
  String get m005;

  /// No description provided for @m006.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get m006;

  /// Actualizado a las {v0}
  ///
  /// In es, this message translates to:
  /// **'Actualizado a las {v0}'**
  String m007(String v0);

  /// No description provided for @m008.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get m008;

  /// No description provided for @m009.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y soporte'**
  String get m009;

  /// No description provided for @m010.
  ///
  /// In es, this message translates to:
  /// **'Buscar invitado'**
  String get m010;

  /// No description provided for @m011.
  ///
  /// In es, this message translates to:
  /// **'Cada detalle, con calma.'**
  String get m011;

  /// No description provided for @m012.
  ///
  /// In es, this message translates to:
  /// **'Cada respuesta se refleja automáticamente.'**
  String get m012;

  /// No description provided for @m013.
  ///
  /// In es, this message translates to:
  /// **'Cada sí, un poco más cerca.'**
  String get m013;

  /// No description provided for @m014.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get m014;

  /// No description provided for @m015.
  ///
  /// In es, this message translates to:
  /// **'Celebración realizada'**
  String get m015;

  /// No description provided for @m016.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get m016;

  /// No description provided for @m017.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get m017;

  /// No description provided for @m018.
  ///
  /// In es, this message translates to:
  /// **'Con tu cuenta del estudio web.'**
  String get m018;

  /// No description provided for @m019.
  ///
  /// In es, this message translates to:
  /// **'Condiciones'**
  String get m019;

  /// No description provided for @m020.
  ///
  /// In es, this message translates to:
  /// **'Confirmaciones'**
  String get m020;

  /// No description provided for @m021.
  ///
  /// In es, this message translates to:
  /// **'Confirmaciones y regalos,\nen un solo lugar.'**
  String get m021;

  /// No description provided for @m022.
  ///
  /// In es, this message translates to:
  /// **'Confirmaron'**
  String get m022;

  /// No description provided for @m023.
  ///
  /// In es, this message translates to:
  /// **'Confirmó'**
  String get m023;

  /// No description provided for @m024.
  ///
  /// In es, this message translates to:
  /// **'Consultar mesas'**
  String get m024;

  /// No description provided for @m025.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get m025;

  /// No description provided for @m026.
  ///
  /// In es, this message translates to:
  /// **'Continuar en la web'**
  String get m026;

  /// No description provided for @m027.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get m027;

  /// No description provided for @m028.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get m028;

  /// No description provided for @m029.
  ///
  /// In es, this message translates to:
  /// **'Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí los regalos y quién los reservó.'**
  String get m029;

  /// No description provided for @m030.
  ///
  /// In es, this message translates to:
  /// **'Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí quién confirmó su asistencia.'**
  String get m030;

  /// No description provided for @m031.
  ///
  /// In es, this message translates to:
  /// **'Cuando alguien reserve un regalo, verás aquí su nombre y lo que ha elegido.'**
  String get m031;

  /// No description provided for @m032.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get m032;

  /// No description provided for @m033.
  ///
  /// In es, this message translates to:
  /// **'Declinó'**
  String get m033;

  /// No description provided for @m034.
  ///
  /// In es, this message translates to:
  /// **'Detalles con cariño.'**
  String get m034;

  /// No description provided for @m035.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get m035;

  /// No description provided for @m036.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get m036;

  /// No description provided for @m037.
  ///
  /// In es, this message translates to:
  /// **'El acceso con Google se interrumpió. Vuelve a intentarlo.'**
  String get m037;

  /// No description provided for @m038.
  ///
  /// In es, this message translates to:
  /// **'El nombre se guardó, pero la foto no se pudo actualizar. Puedes volver a intentarlo.'**
  String get m038;

  /// No description provided for @m039.
  ///
  /// In es, this message translates to:
  /// **'Elegir evento'**
  String get m039;

  /// No description provided for @m040.
  ///
  /// In es, this message translates to:
  /// **'Elige un evento para consultar su información.'**
  String get m040;

  /// No description provided for @m041.
  ///
  /// In es, this message translates to:
  /// **'Elige una foto de menos de 10 MB.'**
  String get m041;

  /// No description provided for @m042.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get m042;

  /// No description provided for @m043.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta en la web'**
  String get m043;

  /// Eliminar mi cuenta y datos de {v0}
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta y datos de {v0}'**
  String m044(String v0);

  /// No description provided for @m045.
  ///
  /// In es, this message translates to:
  /// **'Entrando…'**
  String get m045;

  /// No description provided for @m046.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get m046;

  /// No description provided for @m047.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña.'**
  String get m047;

  /// No description provided for @m048.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo electrónico.'**
  String get m048;

  /// No description provided for @m049.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre de 2 a 80 caracteres.'**
  String get m049;

  /// No description provided for @m050.
  ///
  /// In es, this message translates to:
  /// **'Espera un momento y vuelve a intentarlo.'**
  String get m050;

  /// No description provided for @m051.
  ///
  /// In es, this message translates to:
  /// **'Falta 1 día'**
  String get m051;

  /// Faltan {v0} días
  ///
  /// In es, this message translates to:
  /// **'Faltan {v0} días'**
  String m052(String v0);

  /// Foto de perfil de {v0}
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil de {v0}'**
  String m053(String v0);

  /// No description provided for @m054.
  ///
  /// In es, this message translates to:
  /// **'Google no devolvió una identidad. Vuelve a intentarlo.'**
  String get m054;

  /// No description provided for @m055.
  ///
  /// In es, this message translates to:
  /// **'Google no está disponible en este dispositivo. Revisa Google Play Services y vuelve a intentarlo.'**
  String get m055;

  /// No description provided for @m056.
  ///
  /// In es, this message translates to:
  /// **'Google no pudo completar el acceso. Vuelve a intentarlo.'**
  String get m056;

  /// No description provided for @m057.
  ///
  /// In es, this message translates to:
  /// **'Google tardó demasiado en iniciar. Vuelve a intentarlo.'**
  String get m057;

  /// No description provided for @m058.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get m058;

  /// No description provided for @m059.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get m059;

  /// Hace {v0} min
  ///
  /// In es, this message translates to:
  /// **'Hace {v0} min'**
  String m060(String v0);

  /// No description provided for @m061.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get m061;

  /// No description provided for @m062.
  ///
  /// In es, this message translates to:
  /// **'Invitación aún no publicada'**
  String get m062;

  /// No description provided for @m063.
  ///
  /// In es, this message translates to:
  /// **'Invitado'**
  String get m063;

  /// No description provided for @m064.
  ///
  /// In es, this message translates to:
  /// **'Invitados'**
  String get m064;

  /// No description provided for @m065.
  ///
  /// In es, this message translates to:
  /// **'La conexión tardó demasiado. Vuelve a intentarlo.'**
  String get m065;

  /// No description provided for @m066.
  ///
  /// In es, this message translates to:
  /// **'Las confirmaciones llegarán aquí'**
  String get m066;

  /// No description provided for @m067.
  ///
  /// In es, this message translates to:
  /// **'Lo importante, cerca.'**
  String get m067;

  /// No description provided for @m068.
  ///
  /// In es, this message translates to:
  /// **'Los detalles también tienen su tiempo'**
  String get m068;

  /// No description provided for @m069.
  ///
  /// In es, this message translates to:
  /// **'Los regalos empiezan con tu invitación.'**
  String get m069;

  /// No description provided for @m070.
  ///
  /// In es, this message translates to:
  /// **'Mesa'**
  String get m070;

  /// No description provided for @m071.
  ///
  /// In es, this message translates to:
  /// **'Mesas'**
  String get m071;

  /// No description provided for @m072.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get m072;

  /// No description provided for @m073.
  ///
  /// In es, this message translates to:
  /// **'Nadie queda pendiente'**
  String get m073;

  /// No description provided for @m074.
  ///
  /// In es, this message translates to:
  /// **'No asistirá'**
  String get m074;

  /// No description provided for @m075.
  ///
  /// In es, this message translates to:
  /// **'No asistirán'**
  String get m075;

  /// No description provided for @m076.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ese nombre'**
  String get m076;

  /// No description provided for @m077.
  ///
  /// In es, this message translates to:
  /// **'No hay invitados en esta lista.'**
  String get m077;

  /// No description provided for @m078.
  ///
  /// In es, this message translates to:
  /// **'No hay mesas guardadas.'**
  String get m078;

  /// No description provided for @m079.
  ///
  /// In es, this message translates to:
  /// **'No hay regalos en esta lista.'**
  String get m079;

  /// No description provided for @m080.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace. Inténtalo de nuevo.'**
  String get m080;

  /// No description provided for @m081.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el enlace. Vuelve a intentarlo.'**
  String get m081;

  /// No description provided for @m082.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el selector de Google. Vuelve a intentarlo con la app abierta.'**
  String get m082;

  /// No description provided for @m083.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esta foto. Revisa el acceso a tus fotos y vuelve a intentarlo.'**
  String get m083;

  /// No description provided for @m084.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la invitación. Vuelve a intentarlo.'**
  String get m084;

  /// No description provided for @m085.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la web. Vuelve a intentarlo.'**
  String get m085;

  /// No description provided for @m086.
  ///
  /// In es, this message translates to:
  /// **'No pudimos activar las notificaciones. Vuelve a intentarlo.'**
  String get m086;

  /// No description provided for @m087.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la información. Inténtalo de nuevo.'**
  String get m087;

  /// No description provided for @m088.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las mesas.'**
  String get m088;

  /// No description provided for @m089.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la acción. Vuelve a intentarlo.'**
  String get m089;

  /// No description provided for @m090.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar. Vuelve a intentarlo.'**
  String get m090;

  /// No description provided for @m091.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el perfil. Vuelve a intentarlo.'**
  String get m091;

  /// No description provided for @m092.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar esta foto. Elige otra imagen.'**
  String get m092;

  /// No description provided for @m093.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar este dispositivo. Vuelve a intentarlo.'**
  String get m093;

  /// No description provided for @m094.
  ///
  /// In es, this message translates to:
  /// **'No pudimos validar esta app con Google. Revisa que tengas la versión más reciente.'**
  String get m094;

  /// No description provided for @m095.
  ///
  /// In es, this message translates to:
  /// **'Nombre visible'**
  String get m095;

  /// No description provided for @m096.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get m096;

  /// No description provided for @m097.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones no disponibles. Puedes volver a intentarlo desde tu cuenta.'**
  String get m097;

  /// No description provided for @m098.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get m098;

  /// No description provided for @m099.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get m099;

  /// No description provided for @m100.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get m100;

  /// No description provided for @m101.
  ///
  /// In es, this message translates to:
  /// **'Permite las notificaciones en los ajustes del dispositivo. Si ya lo hiciste, vuelve a intentarlo en unos segundos.'**
  String get m101;

  /// No description provided for @m102.
  ///
  /// In es, this message translates to:
  /// **'Por ahora, ninguna ausencia'**
  String get m102;

  /// No description provided for @m103.
  ///
  /// In es, this message translates to:
  /// **'Por confirmar'**
  String get m103;

  /// Por {v0}
  ///
  /// In es, this message translates to:
  /// **'Por {v0}'**
  String m104(String v0);

  /// No description provided for @m105.
  ///
  /// In es, this message translates to:
  /// **'Preparando foto…'**
  String get m105;

  /// No description provided for @m106.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get m106;

  /// No description provided for @m107.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre.'**
  String get m107;

  /// No description provided for @m108.
  ///
  /// In es, this message translates to:
  /// **'Que empiece la celebración.'**
  String get m108;

  /// No description provided for @m109.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get m109;

  /// No description provided for @m110.
  ///
  /// In es, this message translates to:
  /// **'Regalos'**
  String get m110;

  /// No description provided for @m111.
  ///
  /// In es, this message translates to:
  /// **'Regalos con cariño.'**
  String get m111;

  /// No description provided for @m112.
  ///
  /// In es, this message translates to:
  /// **'Reservado'**
  String get m112;

  /// No description provided for @m113.
  ///
  /// In es, this message translates to:
  /// **'Reservados'**
  String get m113;

  /// No description provided for @m114.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo y contraseña.'**
  String get m114;

  /// No description provided for @m115.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet y vuelve a intentarlo.'**
  String get m115;

  /// No description provided for @m116.
  ///
  /// In es, this message translates to:
  /// **'Sin confirmar'**
  String get m116;

  /// No description provided for @m117.
  ///
  /// In es, this message translates to:
  /// **'Sin elección'**
  String get m117;

  /// No description provided for @m118.
  ///
  /// In es, this message translates to:
  /// **'Sin invitados asignados'**
  String get m118;

  /// No description provided for @m119.
  ///
  /// In es, this message translates to:
  /// **'Sin respuesta'**
  String get m119;

  /// Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contactadme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.
  ///
  /// In es, this message translates to:
  /// **'Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contactadme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.'**
  String m120(String v0);

  /// Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contáctenme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.
  ///
  /// In es, this message translates to:
  /// **'Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contáctenme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.'**
  String m121(String v0);

  /// No description provided for @m122.
  ///
  /// In es, this message translates to:
  /// **'TU CELEBRACIÓN'**
  String get m122;

  /// No description provided for @m123.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get m123;

  /// No description provided for @m124.
  ///
  /// In es, this message translates to:
  /// **'Tu celebración'**
  String get m124;

  /// No description provided for @m125.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get m125;

  /// No description provided for @m126.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get m126;

  /// No description provided for @m127.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene acceso a esta información.'**
  String get m127;

  /// No description provided for @m128.
  ///
  /// In es, this message translates to:
  /// **'Tu gente,\nmás cerca'**
  String get m128;

  /// No description provided for @m129.
  ///
  /// In es, this message translates to:
  /// **'Tu gente,\nmás cerca.'**
  String get m129;

  /// No description provided for @m130.
  ///
  /// In es, this message translates to:
  /// **'Tu gente.'**
  String get m130;

  /// No description provided for @m131.
  ///
  /// In es, this message translates to:
  /// **'Tu invitación empieza en la web.'**
  String get m131;

  /// No description provided for @m132.
  ///
  /// In es, this message translates to:
  /// **'Tu lista, al día.'**
  String get m132;

  /// No description provided for @m133.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión terminó. Vuelve a entrar.'**
  String get m133;

  /// No description provided for @m134.
  ///
  /// In es, this message translates to:
  /// **'Tus invitados y regalos, con calma.'**
  String get m134;

  /// No description provided for @m135.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get m135;

  /// No description provided for @m136.
  ///
  /// In es, this message translates to:
  /// **'Usa tu cuenta del estudio web.'**
  String get m136;

  /// No description provided for @m137.
  ///
  /// In es, this message translates to:
  /// **'VUESTRA CELEBRACIÓN'**
  String get m137;

  /// No description provided for @m138.
  ///
  /// In es, this message translates to:
  /// **'Ver mi invitación'**
  String get m138;

  /// No description provided for @m139.
  ///
  /// In es, this message translates to:
  /// **'Ver y descargar invitación'**
  String get m139;

  /// No description provided for @m140.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get m140;

  /// No description provided for @m141.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentar'**
  String get m141;

  /// No description provided for @m142.
  ///
  /// In es, this message translates to:
  /// **'Vuestra cuenta'**
  String get m142;

  /// No description provided for @m143.
  ///
  /// In es, this message translates to:
  /// **'Ya vienen.'**
  String get m143;

  /// No description provided for @m144.
  ///
  /// In es, this message translates to:
  /// **'no asistirán'**
  String get m144;

  /// No description provided for @m145.
  ///
  /// In es, this message translates to:
  /// **'o con tu correo'**
  String get m145;

  /// No description provided for @m146.
  ///
  /// In es, this message translates to:
  /// **'pendientes'**
  String get m146;

  /// No description provided for @m147.
  ///
  /// In es, this message translates to:
  /// **'persona'**
  String get m147;

  /// No description provided for @m148.
  ///
  /// In es, this message translates to:
  /// **'persona confirmada'**
  String get m148;

  /// No description provided for @m149.
  ///
  /// In es, this message translates to:
  /// **'personas'**
  String get m149;

  /// No description provided for @m150.
  ///
  /// In es, this message translates to:
  /// **'personas confirmadas'**
  String get m150;

  /// {v0} de {v1} regalos reservados.
  ///
  /// In es, this message translates to:
  /// **'{v0} de {v1} regalos reservados.'**
  String m151(String v0, String v1);

  /// {v0} no asistirán
  ///
  /// In es, this message translates to:
  /// **'{v0} no asistirán'**
  String m152(String v0);

  /// {v0} pendientes
  ///
  /// In es, this message translates to:
  /// **'{v0} pendientes'**
  String m153(String v0);

  /// {v0} · Versión {v1}
  ///
  /// In es, this message translates to:
  /// **'{v0} · Versión {v1}'**
  String m154(String v0, String v1);

  /// No description provided for @m155.
  ///
  /// In es, this message translates to:
  /// **'¡Hoy es el día!'**
  String get m155;

  /// No description provided for @m156.
  ///
  /// In es, this message translates to:
  /// **'¿Te han dado acceso como miembro? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.'**
  String get m156;

  /// No description provided for @m157.
  ///
  /// In es, this message translates to:
  /// **'¿Te han dado acceso como pareja? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.'**
  String get m157;

  /// No description provided for @m158.
  ///
  /// In es, this message translates to:
  /// **'Actualizar asistencia'**
  String get m158;

  /// No description provided for @m159.
  ///
  /// In es, this message translates to:
  /// **'Adjunto'**
  String get m159;

  /// No description provided for @m160.
  ///
  /// In es, this message translates to:
  /// **'Adjunto no disponible'**
  String get m160;

  /// No description provided for @m161.
  ///
  /// In es, this message translates to:
  /// **'Adjunto por revisar'**
  String get m161;

  /// No description provided for @m162.
  ///
  /// In es, this message translates to:
  /// **'Adjunto recibido'**
  String get m162;

  /// No description provided for @m163.
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get m163;

  /// No description provided for @m164.
  ///
  /// In es, this message translates to:
  /// **'Atendidas'**
  String get m164;

  /// No description provided for @m165.
  ///
  /// In es, this message translates to:
  /// **'Atendido'**
  String get m165;

  /// No description provided for @m166.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get m166;

  /// No description provided for @m167.
  ///
  /// In es, this message translates to:
  /// **'Añadir acompañante'**
  String get m167;

  /// No description provided for @m168.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay conversaciones'**
  String get m168;

  /// No description provided for @m169.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay mensajes'**
  String get m169;

  /// No description provided for @m170.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay pagos registrados.'**
  String get m170;

  /// No description provided for @m171.
  ///
  /// In es, this message translates to:
  /// **'Billetera digital'**
  String get m171;

  /// No description provided for @m172.
  ///
  /// In es, this message translates to:
  /// **'Buscar invitado o teléfono'**
  String get m172;

  /// No description provided for @m173.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get m173;

  /// No description provided for @m174.
  ///
  /// In es, this message translates to:
  /// **'Cerrar adjunto'**
  String get m174;

  /// No description provided for @m175.
  ///
  /// In es, this message translates to:
  /// **'Conversaciones'**
  String get m175;

  /// No description provided for @m176.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get m176;

  /// No description provided for @m177.
  ///
  /// In es, this message translates to:
  /// **'El comprobante ya está registrado o hubo cambios. Revisa los pagos antes de continuar.'**
  String get m177;

  /// No description provided for @m178.
  ///
  /// In es, this message translates to:
  /// **'El envío necesita verificación en WhatsApp. No lo repitas para evitar duplicados.'**
  String get m178;

  /// No description provided for @m179.
  ///
  /// In es, this message translates to:
  /// **'Elige un invitado'**
  String get m179;

  /// No description provided for @m180.
  ///
  /// In es, this message translates to:
  /// **'Elige una respuesta'**
  String get m180;

  /// No description provided for @m181.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get m181;

  /// No description provided for @m182.
  ///
  /// In es, this message translates to:
  /// **'Enviar respuesta'**
  String get m182;

  /// No description provided for @m183.
  ///
  /// In es, this message translates to:
  /// **'Envío por verificar'**
  String get m183;

  /// No description provided for @m184.
  ///
  /// In es, this message translates to:
  /// **'Escribe un motivo para Tal vez.'**
  String get m184;

  /// No description provided for @m185.
  ///
  /// In es, this message translates to:
  /// **'Excedente'**
  String get m185;

  /// No description provided for @m186.
  ///
  /// In es, this message translates to:
  /// **'Fecha del pago'**
  String get m186;

  /// No description provided for @m187.
  ///
  /// In es, this message translates to:
  /// **'Guardar asistencia'**
  String get m187;

  /// No description provided for @m188.
  ///
  /// In es, this message translates to:
  /// **'Guardar pago'**
  String get m188;

  /// No description provided for @m189.
  ///
  /// In es, this message translates to:
  /// **'Importe recibido'**
  String get m189;

  /// No description provided for @m190.
  ///
  /// In es, this message translates to:
  /// **'Ingresos registrados'**
  String get m190;

  /// No description provided for @m191.
  ///
  /// In es, this message translates to:
  /// **'Introduce un importe válido.'**
  String get m191;

  /// No description provided for @m192.
  ///
  /// In es, this message translates to:
  /// **'Los mensajes de esta conversación aparecerán aquí.'**
  String get m192;

  /// No description provided for @m193.
  ///
  /// In es, this message translates to:
  /// **'Los mensajes que tus invitados envíen por WhatsApp aparecerán aquí.'**
  String get m193;

  /// No description provided for @m194.
  ///
  /// In es, this message translates to:
  /// **'Marcar atendido'**
  String get m194;

  /// No description provided for @m195.
  ///
  /// In es, this message translates to:
  /// **'Marcar pendiente'**
  String get m195;

  /// No description provided for @m196.
  ///
  /// In es, this message translates to:
  /// **'Medio de pago'**
  String get m196;

  /// No description provided for @m197.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get m197;

  /// No description provided for @m198.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la espera'**
  String get m198;

  /// No description provided for @m199.
  ///
  /// In es, this message translates to:
  /// **'Movimientos registrados'**
  String get m199;

  /// No description provided for @m200.
  ///
  /// In es, this message translates to:
  /// **'No enviado'**
  String get m200;

  /// No description provided for @m201.
  ///
  /// In es, this message translates to:
  /// **'No hay conversaciones con estos filtros.'**
  String get m201;

  /// No description provided for @m202.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el adjunto.'**
  String get m202;

  /// No description provided for @m203.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los mensajes.'**
  String get m203;

  /// No description provided for @m204.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los pagos.'**
  String get m204;

  /// No description provided for @m205.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el pago.'**
  String get m205;

  /// No description provided for @m206.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la asistencia.'**
  String get m206;

  /// No description provided for @m207.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la asistencia. Revisa el aforo y el estado de la invitación.'**
  String get m207;

  /// No description provided for @m208.
  ///
  /// In es, this message translates to:
  /// **'Nombre del acompañante'**
  String get m208;

  /// No description provided for @m209.
  ///
  /// In es, this message translates to:
  /// **'Ocultar teclado'**
  String get m209;

  /// No description provided for @m210.
  ///
  /// In es, this message translates to:
  /// **'Pago registrado'**
  String get m210;

  /// No description provided for @m211.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get m211;

  /// No description provided for @m212.
  ///
  /// In es, this message translates to:
  /// **'Pausar reproducción'**
  String get m212;

  /// No description provided for @m213.
  ///
  /// In es, this message translates to:
  /// **'Posible comprobante'**
  String get m213;

  /// No description provided for @m214.
  ///
  /// In es, this message translates to:
  /// **'Prueba otra búsqueda o cambia el filtro.'**
  String get m214;

  /// No description provided for @m215.
  ///
  /// In es, this message translates to:
  /// **'Quitar acompañante'**
  String get m215;

  /// No description provided for @m216.
  ///
  /// In es, this message translates to:
  /// **'Referencia o nota (opcional)'**
  String get m216;

  /// No description provided for @m217.
  ///
  /// In es, this message translates to:
  /// **'Registrar acompañantes ahora'**
  String get m217;

  /// No description provided for @m218.
  ///
  /// In es, this message translates to:
  /// **'Registrar pago'**
  String get m218;

  /// No description provided for @m219.
  ///
  /// In es, this message translates to:
  /// **'Reproducir adjunto'**
  String get m219;

  /// No description provided for @m220.
  ///
  /// In es, this message translates to:
  /// **'Responder'**
  String get m220;

  /// No description provided for @m221.
  ///
  /// In es, this message translates to:
  /// **'Responder por WhatsApp'**
  String get m221;

  /// No description provided for @m222.
  ///
  /// In es, this message translates to:
  /// **'Revisa el nombre de cada acompañante.'**
  String get m222;

  /// No description provided for @m223.
  ///
  /// In es, this message translates to:
  /// **'Saldo de la invitación'**
  String get m223;

  /// No description provided for @m224.
  ///
  /// In es, this message translates to:
  /// **'Saldo pendiente'**
  String get m224;

  /// No description provided for @m225.
  ///
  /// In es, this message translates to:
  /// **'Si dejas la lista vacía, se registrará que asistirá sin acompañantes.'**
  String get m225;

  /// No description provided for @m226.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get m226;

  /// No description provided for @m227.
  ///
  /// In es, this message translates to:
  /// **'Sí, asistirá'**
  String get m227;

  /// No description provided for @m228.
  ///
  /// In es, this message translates to:
  /// **'Tal vez'**
  String get m228;

  /// No description provided for @m229.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get m229;

  /// No description provided for @m230.
  ///
  /// In es, this message translates to:
  /// **'Total esperado'**
  String get m230;

  /// No description provided for @m231.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get m231;

  /// No description provided for @m232.
  ///
  /// In es, this message translates to:
  /// **'Ver adjunto'**
  String get m232;

  /// No description provided for @m233.
  ///
  /// In es, this message translates to:
  /// **'Ver mensajes anteriores'**
  String get m233;

  /// No description provided for @m234.
  ///
  /// In es, this message translates to:
  /// **'Ver más movimientos'**
  String get m234;

  /// No description provided for @m235.
  ///
  /// In es, this message translates to:
  /// **'Verifiqué que recibí este importe.'**
  String get m235;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
