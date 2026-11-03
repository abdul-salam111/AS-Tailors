import '../local_storage/storage.dart';
import 'session_entity.dart';

class SessionController {
  final LocalStorage _localStorage;

  SessionController({required LocalStorage localStorage})
      : _localStorage = localStorage;

  SessionEntity _session = SessionEntity.empty;
  bool get isLoggedIn => _session.isValid;
  SessionEntity get session => _session;

  Future<void> saveSession(SessionEntity session) async {
    _session = session;
    await _localStorage.setValues(StorageKeys.loggedIn, 'true');
    await _localStorage.setValues(StorageKeys.token, session.accessToken);
    if (session.refreshToken != null) {
      await _localStorage.setValues(StorageKeys.refreshToken, session.refreshToken!);
    }
  }

  Future<void> loadSession() async {
    final token = await _localStorage.readValues(StorageKeys.token);
    final refreshToken = await _localStorage.readValues(StorageKeys.refreshToken);
    final loggedIn = await _localStorage.readValues(StorageKeys.loggedIn);
    if (loggedIn == 'true' && token != null && token.isNotEmpty) {
      _session = SessionEntity(accessToken: token, refreshToken: refreshToken);
    }
  }

  Future<void> clearSession() async {
    _session = SessionEntity.empty;
    await _localStorage.clearValues(StorageKeys.loggedIn);
    await _localStorage.clearValues(StorageKeys.token);
    await _localStorage.clearValues(StorageKeys.refreshToken);
    await _localStorage.clearValues(StorageKeys.userDetails);
  }
}
