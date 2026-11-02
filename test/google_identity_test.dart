import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:thedate_app/data/google_identity.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/app_config.dart';

class IdentityPlatform extends GoogleSignInPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  Stream<AuthenticationEvent>? get authenticationEvents => null;
  int cleanupCalls = 0;
  GoogleSignInException? failure;
  @override
  Future<void> init(InitParameters params) async {
    expect(params.serverClientId, AppConfig.googleClient);
  }

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    if (failure != null) throw failure!;
    return const AuthenticationResults(
      user: GoogleSignInUserData(email: 'test@example.test', id: 'test'),
      authenticationTokens: AuthenticationTokenData(
        idToken: 'test-identity-token',
      ),
    );
  }

  @override
  Future<void> signOut(SignOutParams params) async {
    cleanupCalls++;
    throw StateError('Native cleanup unavailable');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GoogleSignInPlatform original;
  late IdentityPlatform platform;
  setUp(() {
    original = GoogleSignInPlatform.instance;
    platform = IdentityPlatform();
    GoogleSignInPlatform.instance = platform;
  });
  tearDown(() => GoogleSignInPlatform.instance = original);
  test(
    'successful identity is returned without a failing sign-out discarding it',
    () async {
      expect(await GoogleIdentity().signIn(), 'test-identity-token');
      expect(platform.cleanupCalls, 0);
    },
  );
  test('cancel does not trigger native cleanup or become an error', () async {
    platform.failure = const GoogleSignInException(
      code: GoogleSignInExceptionCode.canceled,
    );
    expect(await GoogleIdentity().signIn(), isNull);
    expect(platform.cleanupCalls, 0);
  });
  test(
    'provider errors are readable and native logout failure is nonblocking',
    () async {
      platform.failure = const GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
      );
      final identity = GoogleIdentity();
      await expectLater(
        identity.signIn(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Google Play Services'),
          ),
        ),
      );
      await identity.signOut();
      expect(platform.cleanupCalls, 1);
    },
  );
}
