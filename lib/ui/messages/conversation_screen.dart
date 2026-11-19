import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/api_client.dart';
import '../../data/messages_repository.dart';
import '../../domain/invitation_details.dart';
import '../../domain/message_models.dart';
import '../../domain/models.dart';
import '../../l10n/translate.dart';
import '../../state/app_model.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'attachment_screen.dart';
import 'attendance_screen.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'message_options.dart';
import 'payment_form.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.model,
    required this.event,
    required this.guest,
    required this.api,
    required this.pending,
    required this.canPay,
  });

  final AppModel model;
  final Celebration event;
  final Guest guest;
  final MessagesRepository api;
  final bool pending, canPay;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final draft = TextEditingController();
  final scroll = ScrollController();
  late Guest guest = widget.guest;
  late bool pending = widget.pending;
  Timer? ticker;
  List<GuestMessage>? messages;
  GuestMessage? quote;
  bool loading = false, hasMore = false, sending = false, marking = false;
  String? error, readThrough;
  ({String id, String text, String? reply})? outgoing;

  bool get visible => mounted && (ModalRoute.of(context)?.isCurrent ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(initialLoad());
    });
    ticker = Timer.periodic(const Duration(seconds: 12), (_) {
      if (visible) unawaited(load());
    });
  }

  Future<void> initialLoad() async {
    await load();
    if (visible) await sync();
  }

  Future<void> sync() async {
    try {
      await widget.api.syncHistory(guest.id);
      if (visible) await load();
    } catch (_) {
      // An unavailable provider must not hide messages already saved by the API.
    }
  }

  @override
  void dispose() {
    ticker?.cancel();
    draft.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> load({bool older = false}) async {
    if (loading) return;
    setState(() => loading = true);
    try {
      final page = await widget.api.history(
        guest.id,
        before: older ? messages?.lastOrNull?.id : null,
      );
      if (!mounted) return;
      final retained = messages ?? [];
      final incomingIds = page.messages.map((message) => message.id).toSet();
      setState(() {
        messages = older
            ? [
                ...retained,
                ...page.messages.where(
                  (message) => !retained.any((item) => item.id == message.id),
                ),
              ]
            : [
                ...page.messages,
                ...retained.where((item) => !incomingIds.contains(item.id)),
              ];
        if (older || retained.isEmpty || !page.hasMore) hasMore = page.hasMore;
        error = null;
      });
      final last = page.messages
          .where((message) => message.incoming)
          .firstOrNull;
      if (!older && visible && last != null && readThrough != last.id) {
        await widget.api.mark(guest.id, last.id);
        readThrough = last.id;
        if (mounted) {
          setState(
            () => pending =
                pending ||
                (retained.isNotEmpty &&
                    last.id !=
                        retained
                            .where((message) => message.incoming)
                            .firstOrNull
                            ?.id),
          );
        }
      }
    } catch (failure) {
      if (mounted) setState(() => error = problem(failure));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String problem(Object failure) => failure is ApiException
      ? failure.message
      : tr('No pudimos cargar los mensajes.');

  Future<void> attend() async {
    final last = messages?.where((message) => message.incoming).firstOrNull;
    if (last == null || marking) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => marking = true);
    try {
      await widget.api.mark(guest.id, last.id, attended: pending);
      if (mounted) setState(() => pending = !pending);
    } catch (failure) {
      if (mounted) setState(() => error = problem(failure));
    } finally {
      if (mounted) setState(() => marking = false);
    }
  }

  Future<void> send() async {
    final text = draft.text.trim(), quoted = quote?.id;
    if (text.isEmpty || sending) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (outgoing?.text != text || outgoing?.reply != quoted) {
      outgoing = (id: const Uuid().v4(), text: text, reply: quoted);
    }
    setState(() => sending = true);
    try {
      final result = await widget.api.send(
        guest.id,
        outgoing!.id,
        text,
        quoted,
      );
      if (!mounted) return;
      setState(
        () => messages = [
          result,
          ...?messages?.where((item) => item.id != result.id),
        ],
      );
      if (result.delivery == 'sent') {
        setState(() {
          draft.clear();
          quote = null;
          outgoing = null;
          error = null;
        });
      } else {
        setState(
          () => error = tr(
            'El envío necesita verificación en WhatsApp. No lo repitas para evitar duplicados.',
          ),
        );
      }
      if (scroll.hasClients) scroll.jumpTo(0);
    } catch (failure) {
      if (mounted) setState(() => error = problem(failure));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> updateAttendance() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          api: widget.api,
          event: widget.event,
          guest: guest,
        ),
      ),
    );
    if (updated != true || !mounted) return;
    await widget.model.refresh();
    if (!mounted) return;
    setState(
      () => guest =
          widget.model.data?.guests
              .where((item) => item.id == guest.id)
              .firstOrNull ??
          guest,
    );
    unawaited(load());
  }

  Future<void> record(GuestMessage message) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentForm(
          api: widget.api,
          event: widget.event,
          guest: guest,
          receipt: message,
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(
        () => messages = messages?.map((item) {
          if (item.id != message.id) return item;
          return GuestMessage(
            id: item.id,
            text: item.text,
            incoming: item.incoming,
            delivery: item.delivery,
            createdAt: item.createdAt,
            media: item.media,
            paymentRecorded: true,
          );
        }).toList(),
      );
      unawaited(load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = messages;
    return Scaffold(
      appBar: AppBar(
        leading: const MessageBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guest.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              widget.event.title,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: DismissMessageKeyboard(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    if (!eventEnded(widget.event, DateTime.now()))
                      TextButton(
                        onPressed: updateAttendance,
                        child: Text(tr('Actualizar asistencia')),
                      ),
                    if (items?.any((item) => item.incoming) ?? false)
                      TextButton(
                        onPressed: marking ? null : attend,
                        child: Text(
                          pending
                              ? tr('Marcar atendido')
                              : tr('Marcar pendiente'),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: items == null && error == null
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: load,
                        child: ListView.builder(
                          controller: scroll,
                          reverse: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount:
                              (items?.length ?? 0) +
                              (hasMore ? 1 : 0) +
                              ((items?.isEmpty ?? true) ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (items?.isEmpty ?? true) {
                              return EmptyState(
                                title: tr('Aún no hay mensajes'),
                                body: tr(
                                  'Los mensajes de esta conversación aparecerán aquí.',
                                ),
                                icon: Symbol.messages,
                              );
                            }
                            if (index == items!.length) {
                              return TextButton(
                                onPressed: loading
                                    ? null
                                    : () => load(older: true),
                                child: Text(tr('Ver mensajes anteriores')),
                              );
                            }
                            final message = items[index];
                            return Padding(
                              key: ValueKey(message.id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MessageBubble(
                                message: message,
                                openAttachment: () => showMessageAttachment(
                                  context,
                                  widget.api,
                                  message,
                                ),
                                onReply: message.incoming
                                    ? () => setState(() => quote = message)
                                    : null,
                                onPayment:
                                    widget.canPay &&
                                        message.incoming &&
                                        !message.paymentRecorded &&
                                        message.media?.available == true &&
                                        message.media?.receipt == true
                                    ? () => record(message)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Notice(error!, onRetry: items == null ? load : null),
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  children: [
                    if (quote case final GuestMessage source)
                      Row(
                        children: [
                          const AppIcon(Symbol.reply, size: 17),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              source.text.isEmpty
                                  ? tr('Adjunto recibido')
                                  : source.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: tr('Cerrar'),
                            onPressed: () => setState(() => quote = null),
                            icon: const AppIcon(Symbol.close, size: 17),
                          ),
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: MessageInput(
                            key: const Key('whatsapp-draft'),
                            controller: draft,
                            label: tr('Responder por WhatsApp'),
                            keyboardType: TextInputType.multiline,
                            lines: 4,
                            maxLength: 4000,
                            enabled: !sending,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: tr('Enviar respuesta'),
                          onPressed: sending || draft.text.trim().isEmpty
                              ? null
                              : send,
                          icon: AppIcon(
                            Symbol.send,
                            size: 19,
                            color: sending || draft.text.trim().isEmpty
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
