import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
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
                      if (!wedding)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(26, 18, 26, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const BrandWordmark(),
                              SvgPicture.asset(
                                'assets/brand/mark.svg',
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
                                    ? 'Lo importante, cerca.'
                                    : 'Tu gente,\nmás cerca',
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
                                  ? 'Vuestros invitados y regalos, con calma.'
                                  : 'Confirmaciones y regalos,\nen un solo lugar.',
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
                                    const Flexible(
                                      child: Text('Continuar con Google'),
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
                                    'o con tu correo',
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
                                'Correo electrónico',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                            ],
                            TextFormField(
                              controller: email,
                              enabled: !widget.model.busy,
                              autofillHints: const [AutofillHints.username],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: wedding
                                    ? 'tu@email.com'
                                    : 'Correo electrónico',
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
                                  : 'Escribe tu correo electrónico.',
                            ),
                            const SizedBox(height: 12),
                            if (wedding) ...[
                              Text(
                                'Contraseña',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                            ],
                            TextFormField(
                              controller: password,
                              enabled: !widget.model.busy,
                              obscureText: !showPassword,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                hintText: wedding
                                    ? 'Tu contraseña'
                                    : 'Contraseña',
                                prefixIcon: wedding
                                    ? null
                                    : const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: AppIcon(Symbol.lock, size: 19),
                                      ),
                                suffixIcon: IconButton(
                                  tooltip: showPassword
                                      ? 'Ocultar contraseña'
                                      : 'Mostrar contraseña',
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
                                  : 'Escribe tu contraseña.',
                            ),
                            const SizedBox(height: 16),
                            if (widget.model.error != null)
                              Notice(widget.model.error!),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: widget.model.busy ? null : submit,
                                child: Text(
                                  widget.model.busy ? 'Entrando…' : 'Entrar',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                wedding
                                    ? 'Con vuestra cuenta del estudio web.'
                                    : 'Usa tu cuenta del estudio web.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => launchUrl(
                                    Uri.parse(
                                      '${AppConfig.website}/privacidad',
                                    ),
                                  ),
                                  child: const Text('Privacidad'),
                                ),
                                TextButton(
                                  onPressed: () => launchUrl(
                                    Uri.parse('${AppConfig.website}/terminos'),
                                  ),
                                  child: const Text('Condiciones'),
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
