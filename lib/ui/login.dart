import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'widgets/common.dart';

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
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AutofillGroup(
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/brand/mark.svg',
                      width: 56,
                      height: 56,
                      semanticsLabel: AppConfig.name,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConfig.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConfig.loginTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Confirmaciones y regalos, siempre a mano. Entra con tu cuenta del estudio.',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: widget.model.busy
                            ? null
                            : widget.model.loginGoogle,
                        child: const Text('Continuar con Google'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(child: Text('o con tu correo')),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: email,
                      enabled: !widget.model.busy,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      validator: (v) =>
                          v != null &&
                              RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())
                          ? null
                          : 'Escribe tu correo electrónico.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: password,
                      enabled: !widget.model.busy,
                      obscureText: !showPassword,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: TextButton(
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                          child: Text(showPassword ? 'Ocultar' : 'Ver'),
                        ),
                      ),
                      validator: (v) => (v?.isNotEmpty ?? false)
                          ? null
                          : 'Escribe tu contraseña.',
                    ),
                    const SizedBox(height: 24),
                    if (widget.model.error != null) Notice(widget.model.error!),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.model.busy ? null : submit,
                        child: Text(widget.model.busy ? 'Entrando…' : 'Entrar'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      children: [
                        TextButton(
                          onPressed: () => launchUrl(
                            Uri.parse('${AppConfig.website}/privacidad'),
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
            ),
          ),
        ),
      ),
    ),
  );
}
