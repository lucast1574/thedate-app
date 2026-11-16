import '../l10n/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/web_link.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'profile_editor.dart';
import 'widgets/app_icon.dart';
import 'widgets/brand.dart';
import 'widgets/account_avatar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.model});
  final AppModel model;
  Future<void> open(BuildContext context, String path) async {
    await openWebLink(context, Uri.parse(path));
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
                tr("Elegir evento"),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Shortcuts(
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.arrowDown):
                        NextFocusIntent(),
                    SingleActivator(LogicalKeyboardKey.arrowUp):
                        PreviousFocusIntent(),
                  },
                  child: FocusTraversalGroup(
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
        scrollable: true,
        title: Text(tr("Eliminar cuenta en la web")),
        content: Text(
          tr(
            "Abriremos la web de The Date. Inicia sesión con la cuenta que quieres eliminar y confirma allí el borrado. Es permanente: se eliminarán tu perfil, tus eventos, invitados y archivos de este producto. No elimina tu cuenta del otro producto ni tu cuenta de Google. Abrir la web todavía no borra nada.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr("Volver")),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr("Continuar en la web")),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await open(context, AppConfig.deletionUrl);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      Text(
        wedding ? tr("Vuestra cuenta") : tr("Tu cuenta"),
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
            tooltip: tr("Editar perfil"),
            onPressed: model.busy
                ? null
                : () => showProfileEditor(context, model),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLow,
              foregroundColor: Theme.of(context).colorScheme.primary,
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
              wedding ? tr("VUESTRA CELEBRACIÓN") : tr("Tu celebración"),
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
                      ? tr("Activando notificaciones…")
                      : tr("Activar notificaciones"),
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
                title: tr("Ayuda y soporte"),
                onTap: () => open(context, AppConfig.supportUrl),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.lock,
                title: tr("Privacidad"),
                onTap: () => open(context, '${AppConfig.website}/privacidad'),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.file,
                title: tr("Términos y condiciones"),
                onTap: () => open(context, '${AppConfig.website}/terminos'),
              ),
              const Divider(),
              AccountLink(
                icon: Symbol.trash,
                title: tr("Eliminar cuenta"),
                onTap: model.busy ? null : () => deletion(context),
              ),
            ],
          ),
        ),
      ),
      if (wedding) const Divider(),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: model.busy ? null : model.logout,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.error.withValues(alpha: .07),
            foregroundColor: Theme.of(context).colorScheme.error,
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(wedding ? 12 : 16),
            ),
          ),
          icon: AppIcon(
            Symbol.logout,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          label: Text(tr("Cerrar sesión")),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Text(
          tr("{v0} · Versión {v1}", {
            'v0': AppConfig.name,
            'v1': AppConfig.version,
          }),
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
          ? Theme.of(context).colorScheme.error
          : wedding
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: icon == Symbol.logout
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    ),
    trailing: icon == Symbol.logout
        ? null
        : const AppIcon(Symbol.chevron, size: 17),
    onTap: onTap,
  );
}
