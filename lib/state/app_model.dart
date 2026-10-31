import 'package:flutter/foundation.dart';
import '../data/api_client.dart';
import '../data/events_repository.dart';
import '../domain/models.dart';

class AppModel extends ChangeNotifier {
  AppModel(this.repository);
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
    starting = true;
    error = null;
    notifyListeners();
    try {
      account = await repository.restore();
      if (account != null) await _events();
    } catch (e) {
      error = _message(e);
    } finally {
      starting = false;
      notifyListeners();
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
    try {
      final next = await action();
      if (next != null) {
        account = next;
        await _events();
      }
    } catch (e) {
      error = e is ApiException && e.status == 401
          ? 'Revisa tu correo y contraseña.'
          : _message(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _events() async {
    final generation = ++_generation;
    final incoming = await repository.events();
    if (generation != _generation || account == null) return;
    events = incoming;
    if (events.isEmpty) {
      event = null;
      data = null;
      return;
    }
    final previous = event?.id;
    event = events.where((e) => e.id == previous).firstOrNull ?? events.first;
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
    }
  }

  Future<void> select(Celebration selected) async {
    if (busy || event?.id == selected.id) return;
    _generation++;
    event = selected;
    data = null;
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
    await repository.logout();
    account = null;
    events = [];
    event = null;
    data = null;
    updatedAt = null;
    deletionRequested = false;
    _deletionId = null;
    error = null;
    notifyListeners();
  }

  String _message(Object e) => e is ApiException
      ? e.message
      : 'No pudimos completar la acción. Vuelve a intentarlo.';
}
