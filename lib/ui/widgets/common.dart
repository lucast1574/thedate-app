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
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var n = 0; n < labels.length; n++)
        Semantics(
          selected: selected == n,
          button: true,
          child: TextButton(
            onPressed: () => onSelected(n),
            style: TextButton.styleFrom(
              backgroundColor: selected == n
                  ? AppConfig.soft
                  : Colors.transparent,
              foregroundColor: selected == n
                  ? AppConfig.ink
                  : Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(labels[n]),
          ),
        ),
    ],
  );
}
