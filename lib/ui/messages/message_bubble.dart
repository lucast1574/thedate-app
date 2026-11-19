import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/message_models.dart';
import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';
import '../widgets/brand.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.openAttachment,
    this.onReply,
    this.onPayment,
  });

  final GuestMessage message;
  final VoidCallback openAttachment;
  final VoidCallback? onReply, onPayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = message.media;
    final status = [
      if (message.automated) tr('Automático'),
      if (message.createdAt case final DateTime time)
        DateFormat.Md(
          deviceLocale.languageCode,
        ).add_jm().format(time.toLocal()),
      if (message.incoming)
        'WhatsApp'
      else
        switch (message.delivery) {
          'sent' => tr('Enviado'),
          'failed' => tr('No enviado'),
          _ => tr('Envío por verificar'),
        },
    ].join(' · ');
    return Align(
      alignment: message.incoming
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: .9,
        alignment: message.incoming
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Align(
          alignment: message.incoming
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Material(
            color: message.incoming
                ? colors.surfaceContainerLow
                : colors.secondaryContainer,
            borderRadius: BorderRadius.circular(wedding ? 5 : 14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty) SelectableText(message.text),
                  if (media != null) ...[
                    if (message.text.isNotEmpty) const SizedBox(height: 8),
                    Semantics(
                      button: media.available,
                      child: OutlinedButton.icon(
                        key: ValueKey('attachment-${message.id}'),
                        onPressed: media.available ? openAttachment : null,
                        icon: AppIcon(
                          media.image ? Symbol.image : Symbol.file,
                          size: 18,
                        ),
                        label: Text(
                          media.available
                              ? (media.filename.isEmpty
                                    ? tr('Ver adjunto')
                                    : media.filename)
                              : tr('Adjunto no disponible'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  if (onReply == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(status, style: theme.textTheme.bodySmall),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(status, style: theme.textTheme.bodySmall),
                        ),
                        IconButton(
                          tooltip: tr('Responder'),
                          onPressed: onReply,
                          icon: AppIcon(
                            Symbol.reply,
                            size: 17,
                            color: colors.primary,
                          ),
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            minWidth: 44,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  if (message.paymentRecorded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        tr('Pago registrado'),
                        style: theme.textTheme.labelLarge,
                      ),
                    )
                  else if (onPayment != null) ...[
                    const SizedBox(height: 8),
                    if (message.receiptReview != null)
                      Text(
                        message.receiptReview == 'possible'
                            ? tr('Posible comprobante')
                            : tr('Adjunto por revisar'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: onPayment,
                      icon: const AppIcon(Symbol.payment, size: 17),
                      label: Text(tr('Registrar pago')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
