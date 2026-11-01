import 'dart:async';

/// Bus d'événements d'authentification.
///
/// Communique une déconnexion forcée (jeton de rafraîchissement refusé)
/// depuis l'intercepteur Dio vers l'arbre de widgets, sans BuildContext.
class AuthEventBus {
  AuthEventBus._();
  static final AuthEventBus instance = AuthEventBus._();

  final _logoutController = StreamController<void>.broadcast();

  Stream<void> get onLogout => _logoutController.stream;

  void emitLogout() {
    if (!_logoutController.isClosed) _logoutController.add(null);
  }
}
