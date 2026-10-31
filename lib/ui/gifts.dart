import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_config.dart';
import '../domain/models.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key, required this.data});
  final Snapshot data;
  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    final gifts = widget.data.gifts,
        reserved = gifts.where((g) => g.reserved).length;
    final list = gifts.where((g) => filter == 1 || g.reserved).toList()
      ..sort(
        (a, b) => (b.reservedAt ?? DateTime(1970)).compareTo(
          a.reservedAt ?? DateTime(1970),
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConfig.giftsTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$reserved',
              style: TextStyle(
                fontFamily: AppConfig.headingFont,
                fontSize: 56,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text('regalos reservados\nde ${gifts.length} en la lista'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilterTabs(
          labels: const ['Reservados', 'Todos'],
          selected: filter,
          onSelected: (n) => setState(() => filter = n),
        ),
        const SizedBox(height: 24),
        if (list.isEmpty)
          const EmptyState(
            title: 'Los detalles también tienen su tiempo',
            body:
                'Cuando alguien reserve un regalo, verás aquí su nombre y lo que ha elegido.',
            icon: Symbol.gift,
          ),
        ...list.map(
          (gift) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConfig.soft.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.12
                    : 0.5,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIcon(
                  Symbol.gift,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gift.reserved ? gift.guestName : 'Todavía disponible',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (gift.reservedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reservado el ${DateFormat("d 'de' MMMM", 'es').format(gift.reservedAt!.toLocal())}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (gift.delivered) ...[
                        const SizedBox(height: 8),
                        const Text('Recibido'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
