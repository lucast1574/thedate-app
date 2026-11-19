import 'package:flutter/material.dart';

import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';

class MessageBackButton extends StatelessWidget {
  const MessageBackButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => Navigator.of(context).maybePop(),
    icon: const AppIcon(Symbol.back),
  );
}

Future<T?> chooseMessageOption<T>(
  BuildContext context, {
  required String title,
  required List<T> values,
  required String Function(T) label,
  T? selected,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final value in values)
            ListTile(
              title: Text(label(value)),
              selected: value == selected,
              trailing: value == selected
                  ? const AppIcon(Symbol.check, size: 18)
                  : null,
              onTap: () => Navigator.of(context).pop(value),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('Cancelar')),
          ),
        ],
      ),
    ),
  );
}
