import 'package:flutter/material.dart';

import '../../l10n/translate.dart';
import '../widgets/app_icon.dart';

class DismissMessageKeyboard extends StatelessWidget {
  const DismissMessageKeyboard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    excludeFromSemantics: true,
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: child,
  );
}

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.controller,
    required this.label,
    this.action = TextInputAction.done,
    this.keyboardType,
    this.prefix,
    this.lines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction action;
  final TextInputType? keyboardType;
  final Symbol? prefix;
  final int lines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final focus = FocusNode();

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: focus,
    builder: (context, _) => TextField(
      controller: widget.controller,
      focusNode: focus,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.action,
      minLines: 1,
      maxLines: widget.lines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTapOutside: (_) => focus.unfocus(),
      onSubmitted: (_) => focus.unfocus(),
      decoration: InputDecoration(
        labelText: widget.label,
        counterText: '',
        prefixIcon: widget.prefix == null
            ? null
            : Center(widthFactor: 1, child: AppIcon(widget.prefix!, size: 18)),
        suffixIcon: focus.hasFocus
            ? IconButton(
                tooltip: tr('Ocultar teclado'),
                icon: const AppIcon(Symbol.keyboardDown, size: 19),
                onPressed: focus.unfocus,
              )
            : null,
      ),
    ),
  );
}
