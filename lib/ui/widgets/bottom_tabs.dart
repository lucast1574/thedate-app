import '../../l10n/translate.dart';
import 'package:flutter/material.dart';
import 'app_icon.dart';

class BottomTabs extends StatelessWidget {
  const BottomTabs({
    super.key,
    required this.selected,
    required this.onSelected,
    this.unreadMessages = 0,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final int unreadMessages;
  static const messages = 2, account = 3;
  static List<String> get labels => [
    tr("Confirmaciones"),
    tr("Regalos"),
    tr("Mensajes"),
    tr("Cuenta"),
  ];
  static const icons = [
    Symbol.people,
    Symbol.gift,
    Symbol.messages,
    Symbol.user,
  ];

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: SafeArea(
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Semantics(
                selected: selected == index,
                button: true,
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Badge.count(
                          count: unreadMessages,
                          isLabelVisible:
                              index == messages && unreadMessages > 0,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          child: AppIcon(
                            icons[index],
                            color: selected == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontWeight: selected == index
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
