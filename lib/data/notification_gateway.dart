abstract class NotificationGateway {
  Future<void> initialize();
  Stream<String> get registrations;
  Stream<Map<String, dynamic>> get opened;
  Stream<void> get updates;
  Future<bool> register({bool requestPermission = false});
  Future<void> unregister();
  String get platform;
}
