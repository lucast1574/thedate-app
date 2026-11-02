import 'package:flutter/material.dart';
import '../app_config.dart';
import '../domain/models.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';
import 'widgets/brand.dart';
import 'widgets/presentation.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key, required this.data});
  final Snapshot data;
  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  int filter = 0;
  String query = '';
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final list = data.guests
        .where(
          (g) =>
              (filter == 0
                  ? g.confirmed
                  : filter == 1
                  ? g.pending
                  : g.declined) &&
              g.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppConfig.homeTitle),
        const SizedBox(height: 4),
        Text(
          wedding ? 'Cada sí, un poco más cerca.' : 'Tu lista, al día.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        AttendanceSummary(data),
        const SizedBox(height: 8),
        FilterTabs(
          labels: const ['Confirmaron', 'Pendientes', 'No asistirán'],
          selected: filter,
          onSelected: (n) => setState(() => filter = n),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (s) => setState(() => query = s),
          decoration: const InputDecoration(
            hintText: 'Buscar invitado',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: AppIcon(Symbol.search, size: 18),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        if (list.isEmpty)
          EmptyState(
            title: query.isNotEmpty
                ? 'No encontramos ese nombre'
                : filter == 0
                ? 'Las confirmaciones llegarán aquí'
                : filter == 1
                ? 'Nadie queda pendiente'
                : 'Por ahora, ninguna ausencia',
            body: query.isNotEmpty
                ? 'Prueba con otro nombre.'
                : 'Cada respuesta se refleja automáticamente.',
            icon: Symbol.people,
          ),
        for (final guest in list) GuestRow(guest: guest),
      ],
    );
  }
}

class GuestRow extends StatelessWidget {
  const GuestRow({super.key, required this.guest});
  final Guest guest;
  @override
  Widget build(BuildContext context) {
    final g = guest,
        seats = guest.attendingSeats > 0 ? guest.attendingSeats : guest.seats;
    String responseTime = '';
    if (g.respondedAt != null) {
      final age = DateTime.now().difference(g.respondedAt!);
      responseTime = age.inMinutes < 1
          ? 'Ahora'
          : age.inMinutes < 60
          ? 'Hace ${age.inMinutes} min'
          : age.inHours < 24
          ? 'Hoy'
          : '${g.respondedAt!.day}/${g.respondedAt!.month}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: wedding ? 40 : 46,
            height: wedding ? 40 : 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConfig.soft,
            ),
            child: Text(
              g.initials,
              style: TextStyle(
                fontFamily: wedding ? AppConfig.headingFont : 'DM Sans',
                fontSize: wedding ? 17 : 15,
                fontWeight: FontWeight.w600,
                color: AppConfig.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.name,
                  style: wedding
                      ? TextStyle(
                          fontFamily: AppConfig.headingFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        )
                      : Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  g.confirmed
                      ? '$seats ${seats == 1 ? 'persona' : 'personas'}${responseTime.isEmpty ? '' : ' · $responseTime'}'
                      : g.declined
                      ? 'No asistirá'
                      : g.response == 'maybe'
                      ? 'Por confirmar'
                      : 'Sin respuesta',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StateMark(
            g.confirmed
                ? 'Confirmó'
                : g.declined
                ? 'No asistirá'
                : 'Pendiente',
            confirmed: g.confirmed,
          ),
        ],
      ),
    );
  }
}
