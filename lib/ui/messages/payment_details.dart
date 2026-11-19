import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/message_models.dart';
import '../../l10n/translate.dart';

String paymentMoney(GuestAdmission admission, int amount) =>
    NumberFormat.currency(
      locale: deviceLocale.languageCode,
      name: admission.currency,
      symbol: admission.currency,
      decimalDigits: 2,
    ).format(amount / 100);

String paymentMethod(String method) => switch (method) {
  'cash' => tr('Efectivo'),
  'wallet' => tr('Billetera digital'),
  _ => tr('Transferencia'),
};

String paymentDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date);

int? paymentCents(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,7}(?:\.\d{1,2})?$').hasMatch(normalized)) return null;
  final pieces = normalized.split('.');
  final cents =
      int.parse(pieces[0]) * 100 +
      (pieces.length == 2 ? int.parse(pieces[1].padRight(2, '0')) : 0);
  return cents > 0 && cents <= 100000000 ? cents : null;
}
