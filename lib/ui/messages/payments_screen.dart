import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/messages_repository.dart';
import '../../domain/message_models.dart';
import '../../domain/models.dart';
import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'message_input.dart';
import 'payment_details.dart';
import 'payment_form.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({
    super.key,
    required this.api,
    required this.event,
    required this.guests,
    this.revision,
  });
  final MessagesRepository api;
  final Celebration event;
  final List<Guest> guests;
  final DateTime? revision;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<List<GuestPayment>> ledger = widget.api.payments();
  int limit = 20;

  @override
  void didUpdateWidget(covariant PaymentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) ledger = widget.api.payments();
  }

  void reload() => setState(() => ledger = widget.api.payments());

  Future<void> addPayment() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final guest = await showModalBottomSheet<Guest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _PaymentGuestPicker(guests: widget.guests),
    );
    if (!mounted || guest == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PaymentForm(api: widget.api, event: widget.event, guest: guest),
      ),
    );
    if (mounted && saved == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    final admission = widget.event.admission!;
    return FutureBuilder<List<GuestPayment>>(
      future: ledger,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Notice(tr('No pudimos cargar los pagos.'), onRetry: reload);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final payments = [...snapshot.requireData]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final expected = widget.guests.fold(
          0,
          (sum, guest) => sum + admission.total(guest.partySeats),
        );
        final paid = payments.fold(
          0,
          (sum, payment) => sum + payment.amountCents,
        );
        final names = {for (final guest in widget.guests) guest.id: guest.name};
        final theme = Theme.of(context), colors = theme.colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Ingresos registrados'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentMoney(admission, paid),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    if (expected > 0) ...[
                      LinearProgressIndicator(
                        value: (paid / expected).clamp(0, 1).toDouble(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _PaymentMetric(
                          label: tr('Total esperado'),
                          amount: paymentMoney(admission, expected),
                        ),
                        _PaymentMetric(
                          label: paid > expected
                              ? tr('Excedente')
                              : tr('Saldo pendiente'),
                          amount: paymentMoney(
                            admission,
                            (expected - paid).abs(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: widget.guests.isEmpty ? null : addPayment,
              icon: const AppIcon(Symbol.payment, size: 18),
              label: Text(tr('Registrar pago')),
            ),
            const SizedBox(height: 24),
            Text(
              tr('Movimientos registrados'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (payments.isEmpty)
              Text(
                tr('Aún no hay pagos registrados.'),
                style: theme.textTheme.bodySmall,
              ),
            for (final payment in payments.take(limit))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(names[payment.guestId] ?? tr('Invitado')),
                subtitle: Text(
                  [
                    paymentMethod(payment.method),
                    if (DateTime.tryParse(payment.paidOn)
                        case final DateTime date)
                      paymentDate(context, date),
                    if (payment.reference.isNotEmpty) payment.reference,
                  ].join(' · '),
                ),
                trailing: Text(
                  paymentMoney(admission, payment.amountCents),
                  style: theme.textTheme.labelLarge,
                ),
              ),
            if (payments.length > limit)
              TextButton(
                onPressed: () => setState(() => limit += 20),
                child: Text(tr('Ver más movimientos')),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _PaymentMetric extends StatelessWidget {
  const _PaymentMetric({required this.label, required this.amount});
  final String label, amount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(amount, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _PaymentGuestPicker extends StatefulWidget {
  const _PaymentGuestPicker({required this.guests});
  final List<Guest> guests;
  @override
  State<_PaymentGuestPicker> createState() => _PaymentGuestPickerState();
}

class _PaymentGuestPickerState extends State<_PaymentGuestPicker> {
  final filter = TextEditingController();

  @override
  void dispose() {
    filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = filter.text.toLowerCase().trim();
    final matches = widget.guests
        .where((guest) => guest.name.toLowerCase().contains(query))
        .toList();
    return AnimatedPadding(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 160),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: .7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              children: [
                Text(
                  tr('Elige un invitado'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                MessageInput(
                  controller: filter,
                  label: tr('Buscar invitado'),
                  action: TextInputAction.search,
                  prefix: Symbol.search,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: matches.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(matches[index].name),
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context).pop(matches[index]);
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('Cancelar')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
