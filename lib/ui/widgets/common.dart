import 'package:flutter/material.dart';
import '../../app_config.dart';
import 'app_icon.dart';

class Notice extends StatelessWidget {
  const Notice(this.message, {super.key, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.soft.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Volver a intentar'),
            ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title, body;
  final Symbol icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        AppIcon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var n = 0; n < labels.length; n++)
        Expanded(
          child: Semantics(
            selected: selected == n,
            button: true,
            child: InkWell(
              onTap: () => onSelected(n),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected == n
                          ? AppConfig.accent
                          : Theme.of(context).dividerColor,
                      width: selected == n ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[n],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConfig.product == 'wedding'
                        ? AppConfig.headingFont
                        : 'DM Sans',
                    fontSize: AppConfig.product == 'wedding' ? 15 : 13,
                    fontWeight: selected == n
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected == n
                        ? AppConfig.accent
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
