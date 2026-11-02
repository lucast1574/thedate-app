import 'package:flutter/material.dart';
import '../app_config.dart';
import '../domain/models.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';
import 'widgets/brand.dart';
import 'widgets/presentation.dart';
import 'widgets/gift_picture.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key, required this.data, this.token});
  final String? token;
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
        SectionTitle(AppConfig.giftsTitle),
        const SizedBox(height: 5),
        Text(
          '$reserved de ${gifts.length} regalos reservados.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 15),
        FilterTabs(
          labels: const ['Reservados', 'Todos'],
          selected: filter,
          onSelected: (n) => setState(() => filter = n),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          const EmptyState(
            title: 'Los detalles también tienen su tiempo',
            body:
                'Cuando alguien reserve un regalo, verás aquí su nombre y lo que ha elegido.',
            icon: Symbol.gift,
          ),
        for (final gift in list) GiftRow(gift: gift, token: widget.token),
      ],
    );
  }
}

class GiftRow extends StatelessWidget {
  const GiftRow({super.key, required this.gift, this.token});
  final String? token;
  final Gift gift;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = wedding ? AppConfig.accent : const Color(0xFF31886D);
    return Container(
      margin: EdgeInsets.only(bottom: wedding ? 0 : 12),
      padding: EdgeInsets.symmetric(horizontal: wedding ? 0 : 12, vertical: 16),
      decoration: BoxDecoration(
        color: wedding
            ? Colors.transparent
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(wedding ? 0 : 18),
        border: wedding
            ? Border(bottom: BorderSide(color: theme.dividerColor))
            : Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(wedding ? 10 : 12),
            child: Container(
              width: 76,
              height: 76,
              padding: const EdgeInsets.all(4),
              color: Colors.white,
              child: GiftPicture(
                gift.imageUrl,
                token: token,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                if (gift.reserved)
                  Row(
                    children: [
                      AppIcon(Symbol.check, size: 15, color: statusColor),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          gift.delivered ? 'Recibido' : 'Reservado',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text('Disponible', style: theme.textTheme.bodySmall),
                if (gift.reserved) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Por ${gift.guestName}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
