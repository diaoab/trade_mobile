import 'dart:async';

/// Bus d'événements d'authentification.
///
/// Communique une déconnexion forcée (jeton de rafraîchissement refusé,
/// compte désactivé) depuis l'intercepteur Dio vers l'arbre de widgets,
/// sans BuildContext. L'événement porte le message à afficher, s'il y en a un.
class AuthEventBus {
  AuthEventBus._();
  static final AuthEventBus instance = AuthEventBus._();

  final _logoutController = StreamController<String?>.broadcast();

  Stream<String?> get onLogout => _logoutController.stream;

  void emitLogout([String? message]) {
    if (!_logoutController.isClosed) _logoutController.add(message);
  }
}
