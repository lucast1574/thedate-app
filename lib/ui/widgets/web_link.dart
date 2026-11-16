import '../../l10n/translate.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Open a web page in a browser surface without invoking unrelated app handlers.
Future<bool> openWebLink(BuildContext context, Uri uri) async {
  var opened = false;
  if (uri.scheme == 'https' && uri.host.isNotEmpty) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      // Keep browser failures recoverable, including platform-channel failures.
    }
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr("No pudimos abrir el enlace. Inténtalo de nuevo.")),
      ),
    );
  }
  return opened;
}
