import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/messages_repository.dart';
import '../../domain/models.dart';
import '../../l10n/translate.dart';
import '../widgets/common.dart';
import 'message_input.dart';
import 'message_options.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.api,
    required this.event,
    required this.guest,
  });
  final MessagesRepository api;
  final Celebration event;
  final Guest guest;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String choice = widget.guest.response == 'pending'
      ? ''
      : widget.guest.response;
  late final reason = TextEditingController(text: widget.guest.maybeReason);
  late final companions = [
    for (final person in widget.guest.companionDetails)
      _CompanionFields(person),
  ];
  bool saving = false, editParty = false;
  String? error;

  @override
  void dispose() {
    reason.dispose();
    for (final person in companions) {
      person.dispose();
    }
    super.dispose();
  }

  String label(String choice) => switch (choice) {
    'going' => tr('Sí, asistirá'),
    'not_going' => tr('No asistirá'),
    'maybe' => tr('Tal vez'),
    _ => tr('Elige una respuesta'),
  };

  Future<void> save() async {
    if (saving || choice.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (choice == 'maybe' && reason.text.trim().length < 3) {
      setState(() => error = tr('Escribe un motivo para Tal vez.'));
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.api.updateAttendance(
        widget.guest.id,
        choice,
        choice == 'maybe' ? reason.text.trim() : '',
        choice == 'going' && editParty
            ? [
                for (final item in companions)
                  GuestCompanion(item.name.text, item.last.text, item.gender),
              ]
            : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (failure) {
      if (mounted) {
        setState(
          () => error = failure is ApiException
              ? failure.message
              : tr('No pudimos guardar la asistencia.'),
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
      title: Text(tr('Actualizar asistencia')),
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
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final value = await chooseMessageOption(
                        context,
                        title: tr('Actualizar asistencia'),
                        values: [
                          'going',
                          'not_going',
                          if (widget.event.maybeEnabled) 'maybe',
                        ],
                        label: label,
                        selected: choice,
                      );
                      if (value != null && mounted) {
                        setState(() => choice = value);
                      }
                    },
              child: Text(label(choice)),
            ),
            if (choice == 'maybe') ...[
              const SizedBox(height: 16),
              MessageInput(
                controller: reason,
                label: tr('Motivo de la espera'),
                keyboardType: TextInputType.multiline,
                lines: 4,
                maxLength: 2000,
                enabled: !saving,
              ),
            ],
            if (choice == 'going' && widget.guest.seats > 1) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('Registrar acompañantes ahora')),
                value: editParty,
                onChanged: saving
                    ? null
                    : (value) => setState(() => editParty = value ?? false),
              ),
              if (editParty) ...[
                Text(
                  tr(
                    'Si dejas la lista vacía, se registrará que asistirá sin acompañantes.',
                  ),
                ),
                for (final person in companions) ...[
                  const SizedBox(height: 16),
                  MessageInput(
                    controller: person.name,
                    label: tr('Nombre del acompañante'),
                    maxLength: 120,
                    enabled: !saving,
                  ),
                  const SizedBox(height: 8),
                  MessageInput(
                    controller: person.last,
                    label: tr('Apellido'),
                    maxLength: 80,
                    enabled: !saving,
                  ),
                  TextButton(
                    onPressed: saving
                        ? null
                        : () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() => companions.remove(person));
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => person.dispose(),
                            );
                          },
                    child: Text(tr('Quitar acompañante')),
                  ),
                ],
                if (companions.length < widget.guest.seats - 1)
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => setState(
                            () => companions.add(_CompanionFields()),
                          ),
                    child: Text(tr('Añadir acompañante')),
                  ),
              ],
            ],
            const SizedBox(height: 20),
            if (error != null) Notice(error!),
            FilledButton(
              onPressed: saving || choice.isEmpty ? null : save,
              child: Text(saving ? tr('Guardando…') : tr('Guardar asistencia')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CompanionFields {
  _CompanionFields([GuestCompanion? person])
    : name = TextEditingController(text: person?.name),
      last = TextEditingController(text: person?.lastName),
      gender = person?.gender ?? 'unspecified';

  final TextEditingController name, last;
  final String gender;

  void dispose() {
    name.dispose();
    last.dispose();
  }
}
