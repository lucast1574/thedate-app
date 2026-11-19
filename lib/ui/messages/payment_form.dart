import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/api_client.dart';
import '../../data/messages_repository.dart';
import '../../domain/invitation_details.dart';
import '../../domain/message_models.dart';
import '../../domain/models.dart';
import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'attachment_screen.dart';
import 'message_input.dart';
import 'message_options.dart';
import 'payment_details.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({
    super.key,
    required this.api,
    required this.event,
    required this.guest,
    this.receipt,
  });
  final MessagesRepository api;
  final Celebration event;
  final Guest guest;
  final GuestMessage? receipt;

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final amount = TextEditingController(), note = TextEditingController();
  final requestId = const Uuid().v4();
  late DateTime date = DateUtils.dateOnly(
    eventLocalTime(widget.event, DateTime.now()),
  );
  late Future<List<GuestPayment>> ledger = widget.api.payments();
  String method = 'transfer';
  bool verified = false, saving = false;
  String? error;

  GuestAdmission get admission => widget.event.admission!;

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !verified) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final cents = paymentCents(amount.text);
    if (cents == null) {
      setState(() => error = tr('Introduce un importe válido.'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.api.recordPayment({
        'id': requestId,
        'guestId': widget.guest.id,
        if (widget.receipt case final GuestMessage receipt)
          'messageId': receipt.id,
        'amountCents': cents,
        'currency': admission.currency,
        'paidOn': DateFormat('yyyy-MM-dd', 'en').format(date),
        'method': method,
        'reference': note.text.trim(),
        'verified': true,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('Pago registrado'))));
      Navigator.of(context).pop(true);
    } catch (failure) {
      if (mounted) {
        setState(
          () => error = failure is ApiException
              ? failure.message
              : tr('No pudimos guardar el pago.'),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const MessageBackButton(),
      title: Text(tr('Registrar pago')),
    ),
    body: DismissMessageKeyboard(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              widget.guest.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (widget.receipt case final GuestMessage receipt) ...[
              OutlinedButton.icon(
                onPressed: saving
                    ? null
                    : () => showMessageAttachment(context, widget.api, receipt),
                icon: const AppIcon(Symbol.file, size: 18),
                label: Text(tr('Ver adjunto')),
              ),
              const SizedBox(height: 16),
            ],
            FutureBuilder<List<GuestPayment>>(
              future: ledger,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Notice(
                    tr('No pudimos cargar los pagos.'),
                    onRetry: () =>
                        setState(() => ledger = widget.api.payments()),
                  );
                }
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final paid = snapshot.requireData
                    .where((item) => item.guestId == widget.guest.id)
                    .fold(0, (sum, item) => sum + item.amountCents);
                final due = max(
                  0,
                  admission.total(widget.guest.partySeats) - paid,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('Saldo de la invitación')),
                  subtitle: Text(
                    paymentMoney(admission, due),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            MessageInput(
              controller: amount,
              label: '${tr('Importe recibido')} · ${admission.currency}',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              maxLength: 12,
              enabled: !saving,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final today = DateUtils.dateOnly(
                        eventLocalTime(widget.event, DateTime.now()),
                      );
                      final changed = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1900),
                        lastDate: today,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                      );
                      if (mounted && changed != null) {
                        setState(() => date = changed);
                      }
                    },
              icon: const AppIcon(Symbol.calendar, size: 18),
              label: Text(
                '${tr('Fecha del pago')} · ${paymentDate(context, date)}',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      final changed = await chooseMessageOption(
                        context,
                        title: tr('Medio de pago'),
                        values: ['transfer', 'wallet', 'cash'],
                        label: paymentMethod,
                        selected: method,
                      );
                      if (mounted && changed != null) {
                        setState(() => method = changed);
                      }
                    },
              icon: const AppIcon(Symbol.payment, size: 18),
              label: Text(paymentMethod(method)),
            ),
            const SizedBox(height: 12),
            MessageInput(
              controller: note,
              label: tr('Referencia o nota (opcional)'),
              keyboardType: TextInputType.multiline,
              lines: 3,
              maxLength: 500,
              enabled: !saving,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('Verifiqué que recibí este importe.')),
              value: verified,
              onChanged: saving
                  ? null
                  : (value) => setState(() => verified = value ?? false),
            ),
            const SizedBox(height: 16),
            if (error != null) Notice(error!),
            FilledButton(
              onPressed: verified && !saving ? save : null,
              child: Text(saving ? tr('Guardando…') : tr('Guardar pago')),
            ),
          ],
        ),
      ),
    ),
  );
}
