import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/ui/widgets/account_avatar.dart';

void main() {
  test('Google profile metadata is read from the backend session', () {
    final account = Account.fromJson({
      'id': 'u',
      'name': 'User Name',
      'email': 'u@example.test',
      'googlePhotoUrl': 'https://lh3.googleusercontent.com/photo',
      'avatarVersion': 123,
    });
    expect(account.googlePhotoUrl, 'https://lh3.googleusercontent.com/photo');
    expect(account.avatarVersion, 123);
  });
  testWidgets('Google photo never receives the API bearer token', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AccountAvatar(
          account: Account(
            id: 'u',
            name: 'User Name',
            email: 'u@example.test',
            googlePhotoUrl: 'https://lh3.googleusercontent.com/photo',
          ),
          token: 'private-api-session',
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    final provider = (image.image as ResizeImage).imageProvider as NetworkImage;
    expect(provider.url, 'https://lh3.googleusercontent.com/photo');
    expect(provider.headers, isNull);
    await tester.pumpAndSettle();
  });
  testWidgets(
    'custom avatar takes priority, is authenticated and has a per-user cache key',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccountAvatar(
            account: Account(
              id: 'user-one',
              name: 'User Name',
              email: 'u@example.test',
              googlePhotoUrl: 'https://lh3.googleusercontent.com/photo',
              avatarVersion: 123,
            ),
            token: 'private-api-session',
          ),
        ),
      );
      final image = tester.widget<Image>(find.byType(Image));
      final provider =
          (image.image as ResizeImage).imageProvider as NetworkImage;
      expect(provider.url, endsWith('/profile/avatar?v=123&u=user-one'));
      expect(provider.headers, {'Authorization': 'Bearer private-api-session'});
      await tester.pumpAndSettle();
    },
  );
}
