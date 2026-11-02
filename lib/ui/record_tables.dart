import 'package:flutter/material.dart';
import '../data/events_repository.dart';
import '../domain/models.dart';

class RecordTables extends StatefulWidget {
  const RecordTables({
    super.key,
    required this.eventId,
    required this.repository,
    required this.data,
  });
  final String eventId;
  final EventsRepository repository;
  final Snapshot data;
  @override
  State<RecordTables> createState() => _RecordTablesState();
}

class _RecordTablesState extends State<RecordTables> {
  late Future<Map<String, dynamic>> plan;
  @override
  void initState() {
    super.initState();
    plan = load();
  }

  Future<Map<String, dynamic>> load() async => Map<String, dynamic>.from(
    await widget.repository.api.request(
          '/events/${Uri.encodeComponent(widget.eventId)}/seating',
        )
        as Map,
  );
  @override
  Widget build(BuildContext context) => SafeArea(
    child: FractionallySizedBox(
      heightFactor: .75,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mesas',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: plan,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        const Text('No pudimos cargar las mesas.'),
                        TextButton(
                          onPressed: () => setState(() => plan = load()),
                          child: const Text('Volver a intentar'),
                        ),
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tables = snapshot.data!['tables'] as List? ?? [];
                  final assignments =
                      snapshot.data!['assignments'] as Map? ?? {};
                  if (tables.isEmpty) {
                    return const Text('No hay mesas guardadas.');
                  }
                  return ListView(
                    children: tables.map((table) {
                      final names = <String>[];
                      for (final guest in widget.data.guests.where(
                        (guest) => guest.confirmed,
                      )) {
                        if (assignments['${guest.id}~0'] == table['id']) {
                          names.add(guest.name);
                        }
                        for (var i = 0; i < guest.companions.length; i++) {
                          if (assignments['${guest.id}~${i + 1}'] ==
                              table['id']) {
                            names.add(guest.companions[i]);
                          }
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              table['name'] as String? ?? 'Mesa',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              names.isEmpty
                                  ? 'Sin invitados asignados'
                                  : names.join('\n'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
