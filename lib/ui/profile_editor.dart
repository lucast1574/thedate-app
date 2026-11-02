import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/profile_photo_picker.dart';
import '../state/app_model.dart';
import 'widgets/account_avatar.dart';
import 'widgets/app_icon.dart';
import 'widgets/common.dart';

Future<void> showProfileEditor(BuildContext context, AppModel model) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ProfileEditor(model: model),
    );

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key, required this.model});
  final AppModel model;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final form = GlobalKey<FormState>();
  final picker = ProfilePhotoPicker();
  late final TextEditingController name;
  Uint8List? photo;
  bool picking = false, saving = false, closing = false;
  String? error;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.model.account!.name);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void close() {
    if (!mounted || closing || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    closing = true;
    Navigator.pop(context);
  }

  Future<void> choosePhoto() async {
    setState(() {
      picking = true;
      error = null;
    });
    try {
      final chosen = await picker.choose();
      if (mounted && chosen != null) setState(() => photo = chosen);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException
              ? e.message
              : 'No pudimos abrir esta foto. Revisa el acceso a tus fotos y vuelve a intentarlo.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final previousName = widget.model.account!.name;
    setState(() {
      saving = true;
      error = null;
    });
    final saved = await widget.model.saveProfile(
      name.text.trim(),
      photo: photo,
    );
    if (!mounted) return;
    if (saved || widget.model.account == null) {
      close();
      return;
    }
    setState(() {
      saving = false;
      error = previousName != widget.model.account!.name && photo != null
          ? 'El nombre se guardó, pero la foto no se pudo actualizar. Puedes volver a intentarlo.'
          : widget.model.error ??
                'No pudimos guardar el perfil. Vuelve a intentarlo.';
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.model,
    builder: (context, _) {
      final account = widget.model.account;
      if (account == null) {
        if (!closing) {
          WidgetsBinding.instance.addPostFrameCallback((_) => close());
        }
        return const SizedBox.shrink();
      }
      final blocked = picking || saving || widget.model.busy;
      return PopScope(
        canPop: !saving,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Editar perfil',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar',
                          onPressed: blocked ? null : close,
                          icon: const AppIcon(Symbol.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: photo == null
                          ? AccountAvatar(
                              account: account,
                              token: widget.model.repository.api.token,
                            )
                          : ClipOval(
                              child: Image.memory(
                                photo!,
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: blocked ? null : choosePhoto,
                        child: Text(
                          picking ? 'Preparando foto…' : 'Cambiar foto',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: name,
                      enabled: !blocked,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 80,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Nombre visible',
                        counterText: '',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.runes.length < 2 ||
                            text.runes.length > 80 ||
                            RegExp(r'[\x00-\x1f\x7f-\x9f]').hasMatch(text)) {
                          return 'Escribe un nombre de 2 a 80 caracteres.';
                        }
                        return null;
                      },
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Notice(error!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          blocked ||
                              (name.text.trim() == account.name &&
                                  photo == null)
                          ? null
                          : save,
                      child: Text(saving ? 'Guardando…' : 'Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
