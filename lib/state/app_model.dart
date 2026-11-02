import '../domain/invitation_details.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/notification_gateway.dart';
import '../data/api_client.dart';
import '../data/events_repository.dart';
import '../domain/models.dart';

class AppModel extends ChangeNotifier {
  AppModel(this.repository, {this.notifications});
  final NotificationGateway? notifications;
  Future<void>? _pushReady;
  bool _pushInitialized = false;
  bool _openingNotification = false;
  final List<StreamSubscription<dynamic>> _pushSubscriptions = [];
  String? _pendingEvent, _pendingScreen;
  int? notificationTab;
  int _navigationIntent = 0;

  void cancelNotificationNavigation() {
    _navigationIntent++;
    notificationTab = null;
    _pendingEvent = null;
    _pendingScreen = null;
  }

  int? takeNotificationTab() {
    final target = notificationTab;
    notificationTab = null;
    return target;
  }

  String? notificationStatus;
  bool notificationsBusy = false;

  Future<void> _initializePush() async {
    if (notifications == null || _pushInitialized) return;
    try {
      await notifications!.initialize();
      _pushSubscriptions.add(
        notifications!.registrations.listen((fid) async {
          if (account == null) return;
          try {
            await repository.registerDevice(fid, notifications!.platform);
            notificationStatus = 'Notificaciones activadas';
          } catch (_) {
            notificationStatus =
                'No pudimos registrar este dispositivo. Vuelve a intentarlo.';
          }
          notifyListeners();
        }, onError: (Object _) {}),
      );
      _pushSubscriptions.add(notifications!.updates.listen((_) => refresh()));
      _pushSubscriptions.add(
        notifications!.opened.listen((data) {
          _pendingEvent = data['eventId'] as String?;
          _pendingScreen = data['screen'] as String?;
          unawaited(_openNotification());
        }),
      );
      _pushInitialized = true;
    } catch (_) {
      _pushReady = null;
      notificationStatus =
          'Notificaciones no disponibles. Puedes volver a intentarlo desde tu cuenta.';
    }
  }

  Future<void> syncNotifications({bool requestPermission = false}) async {
    if (notifications == null || account == null || notificationsBusy) {
      return;
    }
    notificationsBusy = true;
    notifyListeners();
    try {
      await (_pushReady ??= _initializePush());
      if (!_pushInitialized || account == null) {
        return;
      }
      final registered = await notifications!.register(
        requestPermission: requestPermission,
      );
      if (!registered && requestPermission) {
        notificationStatus =
            'Permite las notificaciones en los ajustes del dispositivo. Si ya lo hiciste, vuelve a intentarlo en unos segundos.';
      }
    } catch (_) {
      notificationStatus =
          'No pudimos activar las notificaciones. Vuelve a intentarlo.';
    } finally {
      notificationsBusy = false;
      notifyListeners();
    }
  }

  Future<void> _openNotification() async {
    if (_openingNotification ||
        account == null ||
        starting ||
        busy ||
        _pendingEvent == null) {
      return;
    }
    _openingNotification = true;
    final eventId = _pendingEvent, screen = _pendingScreen;
    final intent = _navigationIntent;
    _pendingEvent = null;
    _pendingScreen = null;
    try {
      await refresh();
      final selected = events.where((e) => e.id == eventId).firstOrNull;
      if (selected == null || account == null || intent != _navigationIntent) {
        return;
      }
      await select(selected);
      if (event?.id != eventId ||
          account == null ||
          intent != _navigationIntent) {
        return;
      }
      notificationTab = screen == 'gifts' ? 1 : 0;
      notifyListeners();
    } finally {
      _openingNotification = false;
      if (_pendingEvent != null) unawaited(_openNotification());
    }
  }

  @override
  void dispose() {
    for (final subscription in _pushSubscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  final EventsRepository repository;
  Account? account;
  List<Celebration> events = [];
  Celebration? event;
  Snapshot? data;
  DateTime? updatedAt;
  bool starting = true, busy = false;
  String? error;
  int _generation = 0;
  String? _deletionId;
  bool deletionRequested = false;
  Future<void> initialize() async {
    _pushReady ??= _initializePush();
    starting = true;
    error = null;
    notifyListeners();
    try {
      final generation = ++_generation;
      final restored = await repository.restore();
      if (generation != _generation) return;
      account = restored;
      if (account != null) await _events();
    } catch (e) {
      await _handle(e);
    } finally {
      starting = false;
      notifyListeners();
      unawaited(syncNotifications());
      unawaited(_openNotification());
    }
  }

  Future<void> login(String email, String password) =>
      _login(() => repository.login(email, password));
  Future<void> loginGoogle() => _login(repository.loginGoogle);
  Future<void> _login(Future<Account?> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    final generation = ++_generation;
    var authenticated = false;
    try {
      final next = await action();
      if (generation != _generation) return;
      if (next != null) {
        account = next;
        authenticated = true;
        await _events();
      }
    } catch (e) {
      if (authenticated) {
        await _handle(e);
      } else {
        error = e is ApiException && e.status == 401
            ? 'Revisa tu correo y contraseña.'
            : _message(e);
      }
    } finally {
      busy = false;
      notifyListeners();
      unawaited(syncNotifications());
      unawaited(_openNotification());
    }
  }

  bool get viewingRecord => event != null && eventEnded(event!, DateTime.now());

  Future<void> _events() async {
    final generation = ++_generation;
    final incoming = await repository.events();
    if (generation != _generation || account == null) return;
    events = incoming;
    if (events.isEmpty) {
      event = null;
      data = null;
      updatedAt = null;
      return;
    }
    final previous = event?.id;
    event =
        events.where((e) => e.id == previous).firstOrNull ??
        events.where((e) => !eventEnded(e, DateTime.now())).firstOrNull;
    if (event?.id != previous) {
      data = null;
      updatedAt = null;
    }
    await _snapshot();
  }

  Future<void> refresh() async {
    if (busy || account == null) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _events();
    } catch (e) {
      await _handle(e);
    } finally {
      busy = false;
      notifyListeners();
      unawaited(_openNotification());
    }
  }

  Future<void> select(Celebration selected) async {
    if (busy ||
        event?.id == selected.id ||
        !events.any((event) => event.id == selected.id)) {
      return;
    }
    _generation++;
    event = selected;
    data = null;
    updatedAt = null;
    error = null;
    busy = true;
    notifyListeners();
    try {
      await _snapshot();
    } catch (e) {
      await _handle(e);
    } finally {
      busy = false;
      notifyListeners();
      unawaited(_openNotification());
    }
  }

  Future<void> _snapshot() async {
    final selected = event;
    if (selected == null) return;
    final generation = ++_generation;
    final result = await repository.snapshot(selected.id);
    if (generation != _generation) return;
    data = result;
    updatedAt = DateTime.now();
  }

  Future<void> _handle(Object e) async {
    if (e is ApiException && e.status == 401) {
      await logout();
    }
    error = _message(e);
  }

  Future<bool> saveProfile(String name, {Uint8List? photo}) async {
    if (busy || account == null) return false;
    final id = account!.id, generation = ++_generation;
    busy = true;
    error = null;
    notifyListeners();
    try {
      if (name != account!.name) {
        final updated = await repository.updateProfile(name);
        if (generation != _generation || account?.id != id) return false;
        account = updated;
        notifyListeners();
      }
      if (photo != null) {
        final updated = await repository.uploadAvatar(photo);
        if (generation != _generation || account?.id != id) return false;
        account = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      await _handle(e);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    if (busy || deletionRequested) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await repository.requestDeletion(_deletionId ??= repository.deletionId());
      deletionRequested = true;
    } catch (e) {
      await _handle(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _generation++;
    busy = true;
    account = null;
    events = [];
    event = null;
    data = null;
    updatedAt = null;
    notifyListeners();
    if (notifications != null) {
      try {
        await Future.wait([
          notifications!.unregister(),
          repository.removeDevice(),
        ]).timeout(const Duration(seconds: 6));
      } catch (_) {
        /* Local logout still proceeds if the network is unavailable. */
      }
    }
    await repository.logout();
    busy = false;
    account = null;
    events = [];
    event = null;
    data = null;
    updatedAt = null;
    notificationStatus = null;
    notificationTab = null;
    _pendingEvent = null;
    _pendingScreen = null;
    deletionRequested = false;
    _deletionId = null;
    error = null;
    notifyListeners();
  }

  String _message(Object e) => e is ApiException
      ? e.message
      : 'No pudimos completar la acción. Vuelve a intentarlo.';
}
