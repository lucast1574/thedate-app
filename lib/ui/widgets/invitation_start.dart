import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_config.dart';
import 'app_icon.dart';
import 'brand.dart';

class InvitationStart extends StatefulWidget {
  const InvitationStart({super.key, this.gifts = false});
  final bool gifts;
  @override
  State<InvitationStart> createState() => _InvitationStartState();
}

class _InvitationStartState extends State<InvitationStart> {
  bool opening = false;

  Future<void> openWebsite() async {
    if (opening) return;
    setState(() => opening = true);
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(AppConfig.website),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      /* Show the same retryable feedback for unavailable browsers. */
    }
    if (!mounted) return;
    setState(() => opening = false);
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la web. Vuelve a intentarlo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppConfig.soft.withValues(alpha: .65),
                borderRadius: BorderRadius.circular(wedding ? 18 : 28),
              ),
              child: Center(
                child: AppIcon(
                  widget.gifts ? Symbol.gift : Symbol.mail,
                  size: 38,
                  color: AppConfig.accent,
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              widget.gifts
                  ? 'Los regalos empiezan con tu invitación.'
                  : 'Tu invitación empieza en la web.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              widget.gifts
                  ? 'Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí los regalos y quién los reservó.'
                  : 'Crea, personaliza y compra tu invitación en nuestra web. Después, consulta aquí quién confirmó su asistencia.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: opening ? null : openWebsite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          opening ? 'Abriendo la web…' : 'Continuar en la web',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const AppIcon(
                        Symbol.externalLink,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              Uri.parse(AppConfig.website).host,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 26),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 14),
            Text(
              wedding
                  ? '¿Te han dado acceso como pareja? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.'
                  : '¿Te han dado acceso como miembro? Entra con el correo al que te invitaron. Tu celebración aparecerá aquí automáticamente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}
