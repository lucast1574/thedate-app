import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_config.dart';

class GoogleIdentity {
  Future<void>? _initialization;
  Future<String?> signIn() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    final google = GoogleSignIn.instance;
    await (_initialization ??= google.initialize(
      serverClientId: AppConfig.googleClient,
    ));
    try {
      final account = await google.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw StateError('Google no devolvió una identidad.');
      return token;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } finally {
      await google.signOut();
    }
  }
}
