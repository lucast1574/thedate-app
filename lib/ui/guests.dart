import '../l10n/translate.dart';
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
          wedding ? tr("Cada sí, un poco más cerca.") : tr("Tu lista, al día."),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 14),
        AttendanceSummary(data),
        const SizedBox(height: 16),
        FilterTabs(
          labels: [tr("Confirmaron"), tr("Pendientes"), tr("No asistirán")],
          selected: filter,
          onSelected: (n) {
            FocusScope.of(context).unfocus();
            setState(() => filter = n);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardAppearance: Theme.of(context).brightness,
          textInputAction: TextInputAction.search,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          onChanged: (s) => setState(() => query = s),
          decoration: InputDecoration(
            hintText: tr("Buscar invitado"),
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
                ? tr("No encontramos ese nombre")
                : filter == 0
                ? tr("Las confirmaciones llegarán aquí")
                : filter == 1
                ? tr("Nadie queda pendiente")
                : tr("Por ahora, ninguna ausencia"),
            body: query.isNotEmpty
                ? tr("Prueba con otro nombre.")
                : tr("Cada respuesta se refleja automáticamente."),
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
          ? tr("Ahora")
          : age.inMinutes < 60
          ? tr("Hace {v0} min", {'v0': age.inMinutes})
          : age.inHours < 24
          ? tr("Hoy")
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: Text(
              g.initials,
              style: TextStyle(
                fontFamily: wedding ? AppConfig.headingFont : 'DM Sans',
                fontSize: wedding ? 17 : 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
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
                      ? '$seats ${seats == 1 ? tr("persona") : tr("personas")}${responseTime.isEmpty ? '' : ' · $responseTime'}'
                      : g.declined
                      ? tr("No asistirá")
                      : g.response == 'maybe'
                      ? tr("Por confirmar")
                      : tr("Sin respuesta"),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StateMark(
            g.confirmed
                ? tr("Confirmó")
                : g.declined
                ? tr("No asistirá")
                : tr("Pendiente"),
            confirmed: g.confirmed,
          ),
        ],
      ),
    );
  }
}
