import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Jetons de session dans le trousseau (iOS) ou le Keystore (Android).
///
/// Un jeton d'accès expiré n'est pas effacé ici : l'intercepteur reçoit un
/// 401 et le renouvelle avec le jeton de rafraîchissement.
class TokenService {
  final FlutterSecureStorage secureStorage;

  TokenService({required this.secureStorage});

  static const _token = 'auth_token';
  static const _refresh = 'refresh_token';

  Future<String?> getToken() => secureStorage.read(key: _token);

  Future<String?> getRefreshToken() => secureStorage.read(key: _refresh);

  Future<bool> get hasSession async => (await getRefreshToken())?.isNotEmpty ?? false;

  Future<void> saveSession({required String token, required String refreshToken}) async {
    await secureStorage.write(key: _token, value: token);
    await secureStorage.write(key: _refresh, value: refreshToken);
  }

  Future<void> clear() async {
    await secureStorage.delete(key: _token);
    await secureStorage.delete(key: _refresh);
  }
}
