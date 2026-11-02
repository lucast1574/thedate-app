import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_config.dart';
import 'api_client.dart';

class GoogleIdentity {
  Future<void>? _initialization;

  Future<void> _initialize() async {
    try {
      await GoogleSignIn.instance
          .initialize(serverClientId: AppConfig.googleClient)
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  Future<String?> signIn() async {
    try {
      // Google authenticates directly with our API. FCM startup is independent.
      await (_initialization ??= _initialize());
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const ApiException(
          'Google no devolvió una identidad. Vuelve a intentarlo.',
        );
      }
      return token;
    } on GoogleSignInException catch (error) {
      if (kDebugMode) debugPrint('Google sign-in failed: ${error.code.name}');
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw ApiException(switch (error.code) {
        GoogleSignInExceptionCode.clientConfigurationError =>
          'No pudimos validar esta app con Google. Revisa que tengas la versión más reciente.',
        GoogleSignInExceptionCode.providerConfigurationError =>
          'Google no está disponible en este dispositivo. Revisa Google Play Services y vuelve a intentarlo.',
        GoogleSignInExceptionCode.uiUnavailable =>
          'No pudimos abrir el selector de Google. Vuelve a intentarlo con la app abierta.',
        GoogleSignInExceptionCode.interrupted =>
          'El acceso con Google se interrumpió. Vuelve a intentarlo.',
        _ => 'Google no pudo completar el acceso. Vuelve a intentarlo.',
      });
    } on TimeoutException {
      throw const ApiException(
        'Google tardó demasiado en iniciar. Vuelve a intentarlo.',
      );
    }
  }

  Future<void> signOut() async {
    // Cleanup must not replace a valid login token or prevent local logout.
    try {
      await (_initialization ??= _initialize());
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 5));
    } catch (_) {
      if (kDebugMode) debugPrint('Google session cleanup unavailable');
    }
  }
}
