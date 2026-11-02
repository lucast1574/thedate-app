import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'profile_editor.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';
import 'widgets/brand.dart';
import 'widgets/account_avatar.dart';

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
      const SizedBox(height: 8),
      Text(
        wedding ? 'Vuestra cuenta' : 'Tu cuenta',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          AccountAvatar(
            account: model.account!,
            token: model.repository.api.token,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.account!.name,
                  style: wedding
                      ? TextStyle(
                          fontFamily: AppConfig.headingFont,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        )
                      : Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  model.account!.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: model.busy
                ? null
                : () => showProfileEditor(context, model),
            style: IconButton.styleFrom(
              backgroundColor: AppConfig.soft.withValues(alpha: .6),
              foregroundColor: AppConfig.accent,
            ),
            icon: const AppIcon(Symbol.edit, size: 19),
          ),
        ],
      ),
      const SizedBox(height: 24),
      if (wedding) ...[const Divider(), const SizedBox(height: 16)],
      Container(
        padding: EdgeInsets.all(wedding ? 0 : 14),
        decoration: BoxDecoration(
          color: wedding
              ? Colors.transparent
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: wedding
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wedding ? 'VUESTRA CELEBRACIÓN' : 'Tu celebración',
              style: wedding
                  ? Theme.of(context).textTheme.bodySmall
                  : Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            EventPicker(model: model),
          ],
        ),
      ),
      const SizedBox(height: 18),
      if (wedding) ...[const Divider(), const SizedBox(height: 8)],
      Material(
        color: wedding
            ? Colors.transparent
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: wedding ? 0 : 16),
          child: Column(
            children: [
              if (model.notifications != null) ...[
                AccountLink(
                  icon: Symbol.bell,
                  title: model.notificationsBusy
                      ? 'Activando notificaciones…'
                      : 'Activar notificaciones',
                  onTap: model.notificationsBusy
                      ? null
                      : () => model.syncNotifications(requestPermission: true),
                ),
                if (model.notificationStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      model.notificationStatus!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const Divider(),
              ],
              AccountLink(
                icon: Symbol.help,
                title: 'Ayuda y soporte',
                onTap: () => open(
                  context,
                  'mailto:${AppConfig.support}?subject=${Uri.encodeComponent('Ayuda con ${AppConfig.name}')}',
                ),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.lock,
                title: 'Privacidad',
                onTap: () => open(context, '${AppConfig.website}/privacidad'),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.file,
                title: 'Términos y condiciones',
                onTap: () => open(context, '${AppConfig.website}/terminos'),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.trash,
                title: 'Solicitar eliminación de cuenta',
                onTap: model.busy || model.deletionRequested
                    ? null
                    : () => deletion(context),
              ),
            ],
          ),
        ),
      ),
      if (model.deletionRequested)
        const Notice(
          'Solicitud enviada. Te contactaremos en el correo de tu cuenta para continuar.',
        ),
      const SizedBox(height: 20),
      if (wedding) const Divider(),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: model.busy ? null : model.logout,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC94850).withValues(alpha: .07),
            foregroundColor: const Color(0xFFC94850),
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(wedding ? 12 : 16),
            ),
          ),
          icon: const AppIcon(
            Symbol.logout,
            color: Color(0xFFC94850),
            size: 20,
          ),
          label: const Text('Cerrar sesión'),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Text(
          '${AppConfig.name} · Versión 1.0.0',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
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
    minLeadingWidth: 24,
    horizontalTitleGap: 12,
    minVerticalPadding: 10,
    leading: AppIcon(
      icon,
      color: icon == Symbol.logout
          ? const Color(0xFFC94850)
          : wedding
          ? AppConfig.accent
          : Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: icon == Symbol.logout ? const Color(0xFFC94850) : null,
      ),
    ),
    trailing: icon == Symbol.logout
        ? null
        : const AppIcon(Symbol.chevron, size: 17),
    onTap: onTap,
  );
}
