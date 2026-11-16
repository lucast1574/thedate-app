import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

// Resolve the complete preference list; Flutter's default country fallback can
// otherwise choose Spanish before trying the user's second supported language.
Locale resolveAppLocale(List<Locale>? preferences, Iterable<Locale> supported) {
  for (final preference in preferences ?? const <Locale>[]) {
    for (final locale in supported) {
      if (preference.languageCode.toLowerCase() == locale.languageCode) {
        return locale;
      }
    }
  }
  return const Locale('es');
}

Locale get deviceLocale => resolveAppLocale(
  WidgetsBinding.instance.platformDispatcher.locales,
  AppLocalizations.supportedLocales,
);

final _catalogs = <String, AppLocalizations>{};
String tr(String source, [Map<String, Object?> values = const {}]) {
  final locale = deviceLocale;
  final strings = _catalogs.putIfAbsent(
    locale.languageCode,
    () => lookupAppLocalizations(locale),
  );
  switch (source) {
    case "Abriendo la web…":
      return strings.m000;
    case "Abriendo {v0}":
      return strings.m001('${values['v0'] ?? ''}');
    case "Abriendo…":
      return strings.m002;
    case "Abriremos la web de Save the Date. Inicia sesión con la cuenta que quieres eliminar y confirma allí el borrado. Es permanente: se eliminarán tu perfil, tus eventos, invitados y archivos de este producto. No elimina tu cuenta del otro producto ni tu cuenta de Google. Abrir la web todavía no borra nada.":
      return strings.m003;
    case "Abriremos la web de The Date. Inicia sesión con la cuenta que quieres eliminar y confirma allí el borrado. Es permanente: se eliminarán tu perfil, tus eventos, invitados y archivos de este producto. No elimina tu cuenta del otro producto ni tu cuenta de Google. Abrir la web todavía no borra nada.":
      return strings.m004;
    case "Activando notificaciones…":
      return strings.m005;
    case "Activar notificaciones":
      return strings.m006;
    case "Actualizado a las {v0}":
      return strings.m007('${values['v0'] ?? ''}');
    case "Ahora":
      return strings.m008;
    case "Ayuda y soporte":
      return strings.m009;
    case "Buscar invitado":
      return strings.m010;
    case "Cada detalle, con calma.":
      return strings.m011;
    case "Cada respuesta se refleja automáticamente.":
      return strings.m012;
    case "Cada sí, un poco más cerca.":
      return strings.m013;
    case "Cambiar foto":
      return strings.m014;
    case "Celebración realizada":
      return strings.m015;
    case "Cerrar":
      return strings.m016;
    case "Cerrar sesión":
      return strings.m017;
    case "Con tu cuenta del estudio web.":
      return strings.m018;
    case "Condiciones":
      return strings.m019;
    case "Confirmaciones":
      return strings.m020;
    case "Confirmaciones y regalos,\nen un solo lugar.":
      return strings.m021;
    case "Confirmaron":
      return strings.m022;
    case "Confirmó":
      return strings.m023;
    case "Consultar mesas":
      return strings.m024;
    case "Continuar con Google":
      return strings.m025;
    case "Continuar en la web":
      return strings.m026;
    case "Contraseña":
      return strings.m027;
    case "Correo electrónico":
      return strings.m028;
    case "Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí los regalos y quién los reservó.":
      return strings.m029;
    case "Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí quién confirmó su asistencia.":
      return strings.m030;
    case "Cuando alguien reserve un regalo, verás aquí su nombre y lo que ha elegido.":
      return strings.m031;
    case "Cuenta":
      return strings.m032;
    case "Declinó":
      return strings.m033;
    case "Detalles con cariño.":
      return strings.m034;
    case "Disponible":
      return strings.m035;
    case "Editar perfil":
      return strings.m036;
    case "El acceso con Google se interrumpió. Vuelve a intentarlo.":
      return strings.m037;
    case "El nombre se guardó, pero la foto no se pudo actualizar. Puedes volver a intentarlo.":
      return strings.m038;
    case "Elegir evento":
      return strings.m039;
    case "Elige un evento para consultar su información.":
      return strings.m040;
    case "Elige una foto de menos de 10 MB.":
      return strings.m041;
    case "Eliminar cuenta":
      return strings.m042;
    case "Eliminar cuenta en la web":
      return strings.m043;
    case "Eliminar mi cuenta y datos de {v0}":
      return strings.m044('${values['v0'] ?? ''}');
    case "Entrando…":
      return strings.m045;
    case "Entrar":
      return strings.m046;
    case "Escribe tu contraseña.":
      return strings.m047;
    case "Escribe tu correo electrónico.":
      return strings.m048;
    case "Escribe un nombre de 2 a 80 caracteres.":
      return strings.m049;
    case "Espera un momento y vuelve a intentarlo.":
      return strings.m050;
    case "Falta 1 día":
      return strings.m051;
    case "Faltan {v0} días":
      return strings.m052('${values['v0'] ?? ''}');
    case "Foto de perfil de {v0}":
      return strings.m053('${values['v0'] ?? ''}');
    case "Google no devolvió una identidad. Vuelve a intentarlo.":
      return strings.m054;
    case "Google no está disponible en este dispositivo. Revisa Google Play Services y vuelve a intentarlo.":
      return strings.m055;
    case "Google no pudo completar el acceso. Vuelve a intentarlo.":
      return strings.m056;
    case "Google tardó demasiado en iniciar. Vuelve a intentarlo.":
      return strings.m057;
    case "Guardando…":
      return strings.m058;
    case "Guardar cambios":
      return strings.m059;
    case "Hace {v0} min":
      return strings.m060('${values['v0'] ?? ''}');
    case "Hoy":
      return strings.m061;
    case "Invitación aún no publicada":
      return strings.m062;
    case "Invitado":
      return strings.m063;
    case "Invitados":
      return strings.m064;
    case "La conexión tardó demasiado. Vuelve a intentarlo.":
      return strings.m065;
    case "Las confirmaciones llegarán aquí":
      return strings.m066;
    case "Lo importante, cerca.":
      return strings.m067;
    case "Los detalles también tienen su tiempo":
      return strings.m068;
    case "Los regalos empiezan con tu invitación.":
      return strings.m069;
    case "Mesa":
      return strings.m070;
    case "Mesas":
      return strings.m071;
    case "Mostrar contraseña":
      return strings.m072;
    case "Nadie queda pendiente":
      return strings.m073;
    case "No asistirá":
      return strings.m074;
    case "No asistirán":
      return strings.m075;
    case "No encontramos ese nombre":
      return strings.m076;
    case "No hay invitados en esta lista.":
      return strings.m077;
    case "No hay mesas guardadas.":
      return strings.m078;
    case "No hay regalos en esta lista.":
      return strings.m079;
    case "No pudimos abrir el enlace. Inténtalo de nuevo.":
      return strings.m080;
    case "No pudimos abrir el enlace. Vuelve a intentarlo.":
      return strings.m081;
    case "No pudimos abrir el selector de Google. Vuelve a intentarlo con la app abierta.":
      return strings.m082;
    case "No pudimos abrir esta foto. Revisa el acceso a tus fotos y vuelve a intentarlo.":
      return strings.m083;
    case "No pudimos abrir la invitación. Vuelve a intentarlo.":
      return strings.m084;
    case "No pudimos abrir la web. Vuelve a intentarlo.":
      return strings.m085;
    case "No pudimos activar las notificaciones. Vuelve a intentarlo.":
      return strings.m086;
    case "No pudimos cargar la información. Inténtalo de nuevo.":
      return strings.m087;
    case "No pudimos cargar las mesas.":
      return strings.m088;
    case "No pudimos completar la acción. Vuelve a intentarlo.":
      return strings.m089;
    case "No pudimos conectar. Vuelve a intentarlo.":
      return strings.m090;
    case "No pudimos guardar el perfil. Vuelve a intentarlo.":
      return strings.m091;
    case "No pudimos preparar esta foto. Elige otra imagen.":
      return strings.m092;
    case "No pudimos registrar este dispositivo. Vuelve a intentarlo.":
      return strings.m093;
    case "No pudimos validar esta app con Google. Revisa que tengas la versión más reciente.":
      return strings.m094;
    case "Nombre visible":
      return strings.m095;
    case "Notificaciones activadas":
      return strings.m096;
    case "Notificaciones no disponibles. Puedes volver a intentarlo desde tu cuenta.":
      return strings.m097;
    case "Ocultar contraseña":
      return strings.m098;
    case "Pendiente":
      return strings.m099;
    case "Pendientes":
      return strings.m100;
    case "Permite las notificaciones en los ajustes del dispositivo. Si ya lo hiciste, vuelve a intentarlo en unos segundos.":
      return strings.m101;
    case "Por ahora, ninguna ausencia":
      return strings.m102;
    case "Por confirmar":
      return strings.m103;
    case "Por {v0}":
      return strings.m104('${values['v0'] ?? ''}');
    case "Preparando foto…":
      return strings.m105;
    case "Privacidad":
      return strings.m106;
    case "Prueba con otro nombre.":
      return strings.m107;
    case "Que empiece la celebración.":
      return strings.m108;
    case "Recibido":
      return strings.m109;
    case "Regalos":
      return strings.m110;
    case "Regalos con cariño.":
      return strings.m111;
    case "Reservado":
      return strings.m112;
    case "Reservados":
      return strings.m113;
    case "Revisa tu correo y contraseña.":
      return strings.m114;
    case "Sin conexión. Revisa tu internet y vuelve a intentarlo.":
      return strings.m115;
    case "Sin confirmar":
      return strings.m116;
    case "Sin elección":
      return strings.m117;
    case "Sin invitados asignados":
      return strings.m118;
    case "Sin respuesta":
      return strings.m119;
    case "Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contactadme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.":
      return strings.m120('${values['v0'] ?? ''}');
    case "Solicito la eliminación de mi cuenta y de los datos personales asociados en {v0}. Contáctenme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.":
      return strings.m121('${values['v0'] ?? ''}');
    case "TU CELEBRACIÓN":
      return strings.m122;
    case "Todos":
      return strings.m123;
    case "Tu celebración":
      return strings.m124;
    case "Tu contraseña":
      return strings.m125;
    case "Tu cuenta":
      return strings.m126;
    case "Tu cuenta no tiene acceso a esta información.":
      return strings.m127;
    case "Tu gente,\nmás cerca":
      return strings.m128;
    case "Tu gente,\nmás cerca.":
      return strings.m129;
    case "Tu gente.":
      return strings.m130;
    case "Tu invitación empieza en la web.":
      return strings.m131;
    case "Tu lista, al día.":
      return strings.m132;
    case "Tu sesión terminó. Vuelve a entrar.":
      return strings.m133;
    case "Tus invitados y regalos, con calma.":
      return strings.m134;
    case "Términos y condiciones":
      return strings.m135;
    case "Usa tu cuenta del estudio web.":
      return strings.m136;
    case "VUESTRA CELEBRACIÓN":
      return strings.m137;
    case "Ver mi invitación":
      return strings.m138;
    case "Ver y descargar invitación":
      return strings.m139;
    case "Volver":
      return strings.m140;
    case "Volver a intentar":
      return strings.m141;
    case "Vuestra cuenta":
      return strings.m142;
    case "Ya vienen.":
      return strings.m143;
    case "no asistirán":
      return strings.m144;
    case "o con tu correo":
      return strings.m145;
    case "pendientes":
      return strings.m146;
    case "persona":
      return strings.m147;
    case "persona confirmada":
      return strings.m148;
    case "personas":
      return strings.m149;
    case "personas confirmadas":
      return strings.m150;
    case "{v0} de {v1} regalos reservados.":
      return strings.m151('${values['v0'] ?? ''}', '${values['v1'] ?? ''}');
    case "{v0} no asistirán":
      return strings.m152('${values['v0'] ?? ''}');
    case "{v0} pendientes":
      return strings.m153('${values['v0'] ?? ''}');
    case "{v0} · Versión {v1}":
      return strings.m154('${values['v0'] ?? ''}', '${values['v1'] ?? ''}');
    case "¡Hoy es el día!":
      return strings.m155;
    case "¿Te han dado acceso como miembro? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.":
      return strings.m156;
    case "¿Te han dado acceso como pareja? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.":
      return strings.m157;
    default:
      return source;
  }
}
