import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'notification_gateway.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
}

class PushNotifications implements NotificationGateway {
  @override
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';
  @override
  Stream<String> get registrations => FirebaseMessaging.instance.onRegistered;
  @override
  Stream<void> get updates => FirebaseMessaging.onMessage.map((_) {});
  @override
  Stream<Map<String, dynamic>> get opened async* {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) yield initial.data;
    yield* FirebaseMessaging.onMessageOpenedApp.map((message) => message.data);
  }

  @override
  Future<bool> register({bool requestPermission = false}) async {
    final messaging = FirebaseMessaging.instance;
    final permission = requestPermission
        ? await messaging.requestPermission()
        : await messaging.getNotificationSettings();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return false;
    }
    if (Platform.isIOS && await messaging.getAPNSToken() == null) return false;
    await messaging.setAutoInitEnabled(true);
    await messaging.register();
    return true;
  }

  @override
  Future<void> unregister() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
    await FirebaseMessaging.instance.unregister();
  }
}
