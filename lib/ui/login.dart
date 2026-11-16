import '../l10n/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/web_link.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'widgets/brand.dart';
import 'widgets/common.dart';
import 'widgets/app_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.model});
  final AppModel model;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool showPassword = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (form.currentState!.validate()) {
      widget.model.login(email.text.trim(), password.text);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(26, 18, 26, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const BrandWordmark(),
                            if (!wedding)
                              SvgPicture.asset(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'assets/brand/mark-dark.svg'
                                    : 'assets/brand/mark.svg',
                                width: 42,
                                height: 42,
                                excludeFromSemantics: true,
                              ),
                          ],
                        ),
                      ),
                      const AccessArtwork(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          wedding ? 12 : 8,
                          24,
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment: wedding
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: wedding
                                    ? tr("Lo importante, cerca.")
                                    : tr("Tu gente,\nmás cerca"),
                                children: [
                                  if (!wedding)
                                    const TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        color: Color(0xFFE45C87),
                                      ),
                                    ),
                                ],
                              ),
                              textAlign: wedding
                                  ? TextAlign.left
                                  : TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge!
                                  .copyWith(fontSize: wedding ? 33 : 36),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              wedding
                                  ? tr("Tus invitados y regalos, con calma.")
                                  : tr(
                                      "Confirmaciones y regalos,\nen un solo lugar.",
                                    ),
                              textAlign: wedding
                                  ? TextAlign.left
                                  : TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: wedding ? 24 : 28),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: widget.model.busy
                                    ? null
                                    : widget.model.loginGoogle,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppConfig.ink,
                                  side: BorderSide(
                                    color: AppConfig.ink.withValues(alpha: .12),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      wedding ? 5 : 14,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/brand/google.svg',
                                      width: 22,
                                      height: 22,
                                      excludeFromSemantics: true,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(tr("Continuar con Google")),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 17),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    tr("o con tu correo"),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 17),
                            if (wedding) ...[
                              Text(
                                tr("Correo electrónico"),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                            ],
                            TextFormField(
                              controller: email,
                              enabled: !widget.model.busy,
                              autofillHints: const [AutofillHints.username],
                              keyboardType: TextInputType.emailAddress,
                              keyboardAppearance: Theme.of(context).brightness,
                              autocorrect: false,
                              enableSuggestions: false,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: wedding
                                    ? 'tu@email.com'
                                    : tr("Correo electrónico"),
                                prefixIcon: wedding
                                    ? null
                                    : const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: AppIcon(Symbol.mail, size: 19),
                                      ),
                              ),
                              validator: (v) =>
                                  v != null &&
                                      RegExp(
                                        r'^\S+@\S+\.\S+$',
                                      ).hasMatch(v.trim())
                                  ? null
                                  : tr("Escribe tu correo electrónico."),
                            ),
                            const SizedBox(height: 12),
                            if (wedding) ...[
                              Text(
                                tr("Contraseña"),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                            ],
                            TextFormField(
                              controller: password,
                              enabled: !widget.model.busy,
                              obscureText: !showPassword,
                              keyboardAppearance: Theme.of(context).brightness,
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                hintText: wedding
                                    ? tr("Tu contraseña")
                                    : tr("Contraseña"),
                                prefixIcon: wedding
                                    ? null
                                    : const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: AppIcon(Symbol.lock, size: 19),
                                      ),
                                suffixIcon: IconButton(
                                  tooltip: showPassword
                                      ? tr("Ocultar contraseña")
                                      : tr("Mostrar contraseña"),
                                  onPressed: () => setState(
                                    () => showPassword = !showPassword,
                                  ),
                                  icon: AppIcon(
                                    showPassword ? Symbol.eyeOff : Symbol.eye,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (v) => (v?.isNotEmpty ?? false)
                                  ? null
                                  : tr("Escribe tu contraseña."),
                            ),
                            const SizedBox(height: 16),
                            if (widget.model.error != null)
                              Notice(widget.model.error!),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: widget.model.busy ? null : submit,
                                child: Text(
                                  widget.model.busy
                                      ? tr("Entrando…")
                                      : tr("Entrar"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                wedding
                                    ? tr("Con tu cuenta del estudio web.")
                                    : tr("Usa tu cuenta del estudio web."),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () => openWebLink(
                                    context,
                                    Uri.parse(
                                      '${AppConfig.website}/privacidad',
                                    ),
                                  ),
                                  child: Text(tr("Privacidad")),
                                ),
                                TextButton(
                                  onPressed: () => openWebLink(
                                    context,
                                    Uri.parse('${AppConfig.website}/terminos'),
                                  ),
                                  child: Text(tr("Condiciones")),
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
            ),
          ),
        ),
      ),
    ),
  );
}
