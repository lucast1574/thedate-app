import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/messages_repository.dart';
import '../../domain/message_models.dart';
import '../../domain/models.dart';
import '../../l10n/translate.dart';
import '../../state/app_model.dart';
import '../widgets/app_icon.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import '../widgets/presentation.dart';
import 'conversation_screen.dart';
import 'message_input.dart';
import 'payments_screen.dart';

class MessagesHome extends StatefulWidget {
  const MessagesHome({
    super.key,
    required this.model,
    required this.event,
    required this.canPay,
    required this.onUnread,
    required this.initialQuery,
    required this.onQueryChanged,
  });

  final AppModel model;
  final Celebration event;
  final bool canPay;
  final ValueChanged<int> onUnread;
  final String initialQuery;
  final ValueChanged<String> onQueryChanged;

  @override
  State<MessagesHome> createState() => _MessagesHomeState();
}

class _MessagesHomeState extends State<MessagesHome> {
  late final api = MessagesRepository(
    widget.model.repository.api,
    widget.event.id,
  );
  late final search = TextEditingController(text: widget.initialQuery);
  List<GuestConversation>? conversations;
  String? error;
  bool loading = false;
  int filter = 0;
  int section = 0;
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    unawaited(load());
    ticker = Timer.periodic(const Duration(seconds: 15), (_) {
      if ((!widget.canPay || section == 0) &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        unawaited(load());
      }
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    try {
      final list = widget.event.publishedAt == null
          ? <GuestConversation>[]
          : await api.conversations();
      if (!mounted) return;
      setState(() {
        conversations = list;
        error = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onUnread(list.where((item) => item.unread).length);
      });
    } catch (_) {
      if (mounted) {
        setState(() => error = tr('No pudimos cargar los mensajes.'));
      }
    } finally {
      loading = false;
    }
  }

  Future<void> open(Guest guest, GuestConversation conversation) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationScreen(
          model: widget.model,
          event: widget.event,
          guest: guest,
          api: api,
          pending: conversation.pending,
          canPay: widget.canPay,
        ),
      ),
    );
    if (mounted) await load();
  }

  @override
  Widget build(BuildContext context) {
    final guests = {
      for (final guest in widget.model.data?.guests ?? <Guest>[])
        guest.id: guest,
    };
    final query = search.text.trim().toLowerCase();
    final phoneQuery = query.replaceAll(RegExp(r'[^0-9]'), '');
    final visible = (conversations ?? []).where((item) {
      final guest = guests[item.guestId];
      if (guest == null) return false;
      return (guest.name.toLowerCase().contains(query) ||
              (phoneQuery.isNotEmpty &&
                  guest.phone
                      .replaceAll(RegExp(r'[^0-9]'), '')
                      .contains(phoneQuery))) &&
          (filter == 0 ||
              (item.last.incoming && item.pending == (filter == 1)));
    }).toList();
    return DismissMessageKeyboard(
      child: RefreshIndicator(
        onRefresh: () async {
          await widget.model.refresh();
          await load();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverList.list(
                children: [
                  EventPicker(model: widget.model),
                  if (wedding) ...[
                    const SizedBox(height: 12),
                    const BrandRule(),
                  ],
                  const SizedBox(height: 20),
                  SectionTitle(tr('Mensajes')),
                  if (widget.canPay) ...[
                    const SizedBox(height: 16),
                    FilterTabs(
                      labels: [tr('Conversaciones'), tr('Pagos')],
                      selected: section,
                      onSelected: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() => section = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (section == 1 && widget.canPay)
                    PaymentsScreen(
                      api: api,
                      event: widget.event,
                      guests: guests.values.toList(),
                      revision: widget.model.updatedAt,
                    )
                  else ...[
                    MessageInput(
                      controller: search,
                      label: tr('Buscar invitado o teléfono'),
                      action: TextInputAction.search,
                      prefix: Symbol.search,
                      onChanged: (value) {
                        widget.onQueryChanged(value);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final (index, label) in [
                          tr('Todas'),
                          tr('Pendientes'),
                          tr('Atendidas'),
                        ].indexed)
                          ChoiceChip(
                            label: Text(label),
                            selected: filter == index,
                            showCheckmark: false,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onSelected: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() => filter = index);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (error != null) Notice(error!, onRetry: load),
                    if (conversations == null && error == null)
                      const Center(child: CircularProgressIndicator())
                    else if (conversations?.isEmpty ?? false)
                      EmptyState(
                        title: tr('Aún no hay conversaciones'),
                        body: tr(
                          'Los mensajes que tus invitados envíen por WhatsApp aparecerán aquí.',
                        ),
                        icon: Symbol.messages,
                      )
                    else if (visible.isEmpty && error == null)
                      EmptyState(
                        title: tr('No hay conversaciones con estos filtros.'),
                        body: tr('Prueba otra búsqueda o cambia el filtro.'),
                        icon: Symbol.search,
                      ),
                  ],
                ],
              ),
            ),
            if (section == 0 || !widget.canPay)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = visible[index],
                        guest = guests[entry.guestId]!;
                    final theme = Theme.of(context), colors = theme.colorScheme;
                    return Material(
                      color: entry.unread
                          ? colors.surfaceContainerLow
                          : colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(wedding ? 5 : 14),
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        onTap: () => open(guest, entry),
                        minVerticalPadding: 12,
                        leading: CircleAvatar(
                          backgroundColor: colors.secondaryContainer,
                          child: Text(
                            guest.initials,
                            style: TextStyle(
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          guest.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.last.text.isEmpty
                                  ? tr('Adjunto recibido')
                                  : entry.last.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (entry.last.incoming)
                              Text(
                                entry.pending
                                    ? tr('Pendiente')
                                    : tr('Atendido'),
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (entry.last.createdAt case final DateTime time)
                              Text(
                                DateFormat.Md(
                                  deviceLocale.languageCode,
                                ).format(time.toLocal()),
                                style: theme.textTheme.bodySmall,
                              ),
                            if (entry.unread)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Semantics(
                                  label: tr('Sin leer'),
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: colors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
