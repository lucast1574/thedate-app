import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.model});
  final AppModel model;
  Future<void> open(BuildContext context, String path) async {
    final ok = await launchUrl(
      Uri.parse(path),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir el enlace. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  Future<void> selectEvent(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elegir evento',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: model.events
                      .map(
                        (event) => ListTile(
                          title: Text(event.title),
                          selected: model.event?.id == event.id,
                          trailing: model.event?.id == event.id
                              ? const AppIcon(Symbol.check)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            model.select(event);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar eliminación de cuenta'),
        content: const Text(
          'Enviaremos una solicitud para eliminar tu cuenta y sus datos personales. El equipo te contactará en el correo de tu cuenta para verificarla y comunicarte los datos que deban conservarse por obligación legal. Esta acción no elimina la cuenta inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar solicitud'),
          ),
        ],
      ),
    );
    if (confirmed == true) await model.deleteAccount();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tu cuenta', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 24),
      Text(model.account!.name, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(model.account!.email),
      const SizedBox(height: 32),
      const Text(
        'TU EVENTO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const AppIcon(Symbol.calendar),
        title: Text(model.event?.title ?? 'Sin evento activo'),
        subtitle: model.events.length > 1
            ? Text('${model.events.length} eventos · Cambiar evento')
            : null,
        trailing: model.events.length > 1
            ? const AppIcon(Symbol.chevron)
            : null,
        onTap: model.events.length > 1 && !model.busy
            ? () => selectEvent(context)
            : null,
      ),
      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      AccountLink(
        icon: Symbol.mail,
        title: 'Escribir a soporte',
        onTap: () => open(
          context,
          'mailto:${AppConfig.support}?subject=${Uri.encodeComponent('Ayuda con ${AppConfig.name}')}',
        ),
      ),
      AccountLink(
        icon: Symbol.shield,
        title: 'Privacidad',
        onTap: () => open(context, '${AppConfig.website}/privacidad'),
      ),
      AccountLink(
        icon: Symbol.file,
        title: 'Términos y condiciones',
        onTap: () => open(context, '${AppConfig.website}/terminos'),
      ),
      AccountLink(
        icon: Symbol.user,
        title: 'Eliminar mi cuenta',
        onTap: model.busy || model.deletionRequested
            ? null
            : () => deletion(context),
      ),
      if (model.deletionRequested)
        const Notice(
          'Solicitud enviada. Te contactaremos en el correo de tu cuenta para continuar.',
        ),
      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      AccountLink(
        icon: Symbol.logout,
        title: 'Cerrar sesión',
        onTap: model.busy ? null : model.logout,
      ),
      const SizedBox(height: 32),
      const Text('LUCASTUDIOS · 1.0.0', style: TextStyle(fontSize: 12)),
    ],
  );
}

class AccountLink extends StatelessWidget {
  const AccountLink({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final Symbol icon;
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: AppIcon(icon),
    title: Text(title),
    trailing: const AppIcon(Symbol.chevron, size: 18),
    onTap: onTap,
  );
}
