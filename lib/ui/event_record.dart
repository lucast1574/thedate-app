import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_config.dart';
import '../data/events_repository.dart';
import 'record_tables.dart';
import '../domain/models.dart';
import '../domain/invitation_details.dart';

String _partyLabel(Guest guest) {
  final count = guest.attendingSeats > 0 ? guest.attendingSeats : guest.seats;
  return '$count ${count == 1 ? 'persona' : 'personas'}';
}

class EventRecord extends StatelessWidget {
  const EventRecord({
    super.key,
    required this.data,
    required this.repository,
    required this.event,
    required this.gifts,
  });
  final EventsRepository repository;
  final Snapshot data;
  final Celebration event;
  final bool gifts;
  Future<void> open(BuildContext context, String tab) async {
    var ok = false;
    try {
      ok = await launchUrl(
        privateInvitationUri(event, AppConfig.product, tab: tab),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir el enlace. Vuelve a intentarlo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        gifts ? 'Regalos' : 'Invitados',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      if (gifts) ...[
        if (data.gifts.isEmpty) const Text('No hay regalos en esta lista.'),
        ...data.gifts.map(
          (gift) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(gift.title),
            subtitle: Text(
              gift.guestName.isEmpty ? 'Sin elección' : gift.guestName,
            ),
            trailing: Text(
              gift.delivered
                  ? 'Recibido'
                  : gift.reserved
                  ? 'Reservado'
                  : 'Disponible',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ] else ...[
        if (data.guests.isEmpty) const Text('No hay invitados en esta lista.'),
        ...data.guests.map(
          (guest) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(guest.name),
            subtitle: Text(
              guest.confirmed
                  ? 'Confirmó'
                  : guest.declined
                  ? 'Declinó'
                  : 'Sin confirmar',
            ),
            trailing: Text(
              _partyLabel(guest),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => RecordTables(
            eventId: event.id,
            repository: repository,
            data: data,
          ),
        ),
        child: const Text('Consultar mesas'),
      ),
    ],
  );
}
