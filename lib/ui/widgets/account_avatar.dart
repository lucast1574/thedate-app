import 'package:flutter/material.dart';
import '../../app_config.dart';
import '../../domain/models.dart';
import 'brand.dart';
import 'presentation.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.account, this.token});
  final Account account;
  final String? token;

  @override
  Widget build(BuildContext context) {
    final custom = account.avatarVersion > 0;
    final google = Uri.tryParse(account.googlePhotoUrl);
    final source = custom
        ? '${AppConfig.api}/profile/avatar?v=${account.avatarVersion}&u=${Uri.encodeComponent(account.id)}'
        : google?.scheme == 'https' && google!.host.isNotEmpty
        ? google.toString()
        : null;
    final initials = Center(
      child: Text(
        initialsOf(account.name),
        style: TextStyle(
          fontFamily: wedding ? AppConfig.headingFont : 'DM Sans',
          fontSize: wedding ? 30 : 28,
          color: AppConfig.accent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    return Semantics(
      label: 'Foto de perfil de ${account.name}',
      image: true,
      excludeSemantics: true,
      child: ClipOval(
        child: SizedBox(
          width: 76,
          height: 76,
          child: ColoredBox(
            color: AppConfig.soft,
            child: source == null
                ? initials
                : Image.network(
                    source,
                    key: ValueKey('${account.id}:$source'),
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    cacheWidth: 228,
                    headers: custom && token != null
                        ? {'Authorization': 'Bearer $token'}
                        : null,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : initials,
                    errorBuilder: (context, error, stackTrace) => initials,
                  ),
          ),
        ),
      ),
    );
  }
}
