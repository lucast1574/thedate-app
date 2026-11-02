import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../../app_config.dart';
import 'app_icon.dart';

class GiftPicture extends StatelessWidget {
  const GiftPicture(this.url, {super.key, this.token, this.fit = BoxFit.cover});
  final BoxFit fit;
  final String? token;
  final String url;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: AppConfig.soft.withValues(alpha: .55),
      child: const Center(child: AppIcon(Symbol.gift, size: 28)),
    );
    if (kDebugMode && url.startsWith('preview:')) {
      return Image.asset(
        url.substring(8),
        cacheWidth: 240,
        fit: fit,
        errorBuilder: (_, error, stack) => fallback,
      );
    }
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      headers:
          token != null &&
              Uri.tryParse(url)?.origin == Uri.parse(AppConfig.api).origin
          ? {'Authorization': 'Bearer $token'}
          : null,
      fit: fit,
      errorBuilder: (_, error, stack) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}
