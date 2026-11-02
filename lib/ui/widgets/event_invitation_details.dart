import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_config.dart';
import '../../domain/models.dart';
import '../../domain/invitation_details.dart';
import 'app_icon.dart';

class EventInvitationDetails extends StatefulWidget {
  const EventInvitationDetails({super.key, required this.event});
  final Celebration event;
  @override
  State<EventInvitationDetails> createState() => _EventInvitationDetailsState();
}

class _EventInvitationDetailsState extends State<EventInvitationDetails> {
  Timer? timer;
  bool opening = false;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> openInvitation(Uri uri) async {
    if (opening) return;
    setState(() => opening = true);
    var opened = false;
    try {
      final target = eventEnded(widget.event, DateTime.now())
          ? privateInvitationUri(widget.event, AppConfig.product)
          : uri;
      opened = await launchUrl(target, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Unavailable browsers use the same retryable feedback.
    }
    if (!mounted) return;
    setState(() => opening = false);
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la invitación. Vuelve a intentarlo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ended = eventEnded(widget.event, DateTime.now());
    final countdown = ended
        ? null
        : eventCountdown(widget.event, DateTime.now());
    final uri = ended
        ? privateInvitationUri(widget.event, AppConfig.product)
        : generalInvitationUri(widget.event, AppConfig.product);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 0,
        children: [
          if (countdown != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                countdown,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (uri != null)
            TextButton.icon(
              onPressed: opening ? null : () => openInvitation(uri),
              icon: const AppIcon(Symbol.externalLink, size: 16),
              label: Text(
                opening
                    ? 'Abriendo…'
                    : ended
                    ? 'Ver y descargar invitación'
                    : 'Ver mi invitación',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Invitación aún no publicada',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
