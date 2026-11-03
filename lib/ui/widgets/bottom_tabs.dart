import 'package:flutter/material.dart';
import 'app_icon.dart';

class BottomTabs extends StatelessWidget {
  const BottomTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  static const labels = ['Confirmaciones', 'Regalos', 'Cuenta'];
  static const icons = [Symbol.people, Symbol.gift, Symbol.user];

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
                        AppIcon(
                          icons[index],
                          color: selected == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
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
