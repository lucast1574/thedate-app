import 'package:flutter/material.dart';
import '../app_config.dart';
import '../domain/models.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';

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
        Text(
          AppConfig.homeTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConfig.accent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Text(
                '${data.confirmedPeople}',
                style: TextStyle(
                  fontFamily: AppConfig.headingFont,
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.paper,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'personas confirmadas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppConfig.paper,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.pendingInvitations == 0
                          ? 'Sin invitaciones pendientes'
                          : '${data.pendingInvitations} invitaciones por responder',
                      style: TextStyle(fontSize: 12, color: AppConfig.paper),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilterTabs(
          labels: const ['Confirmaron', 'Pendientes', 'No asistirán'],
          selected: filter,
          onSelected: (n) => setState(() => filter = n),
        ),
        if (data.guests.length > 8 || query.isNotEmpty) ...[
          const SizedBox(height: 16),
          TextField(
            onChanged: (s) => setState(() => query = s),
            decoration: const InputDecoration(labelText: 'Buscar por nombre'),
          ),
        ],
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
                : filter == 0
                ? 'Cada respuesta se refleja automáticamente. Puedes seguir con lo tuyo.'
                : 'La lista se actualiza al recibir nuevas respuestas.',
            icon: Symbol.people,
          ),
        ...list.map((g) => GuestRow(guest: g)),
      ],
    );
  }
}

class GuestRow extends StatelessWidget {
  const GuestRow({super.key, required this.guest});
  final Guest guest;
  @override
  Widget build(BuildContext context) {
    final g = guest;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppConfig.soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              g.initials,
              style: TextStyle(
                color: AppConfig.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  g.confirmed
                      ? '${g.attendingSeats > 0 ? g.attendingSeats : g.seats} ${(g.attendingSeats > 0 ? g.attendingSeats : g.seats) == 1 ? 'persona' : 'personas'} · Confirmado'
                      : g.declined
                      ? 'No asistirá'
                      : g.response == 'maybe'
                      ? 'Por confirmar'
                      : 'Sin respuesta',
                ),
                if (g.companions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    g.companions.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (g.confirmed) ...[
            const SizedBox(width: 8),
            AppIcon(
              Symbol.check,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }
}
