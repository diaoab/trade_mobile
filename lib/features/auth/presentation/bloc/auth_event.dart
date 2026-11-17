import '../../domain/entities/user.dart';

abstract class AuthEvent {}

/// Démarrage de l'app : reprise de la session enregistrée.
class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String motDePasse;

  /// `true` : création du compte plutôt que connexion.
  final bool creation;
  LoginRequested({required this.email, required this.motDePasse, this.creation = false});
}

class LogoutRequested extends AuthEvent {}

/// Session refusée par l'API (jeton de rafraîchissement expiré ou révoqué,
/// compte désactivé). [message] : explication de l'API, s'il y en a une.
class SessionExpired extends AuthEvent {
  final String? message;
  SessionExpired({this.message});
}

/// Compte renvoyé par l'API après une modification (profil).
class UserUpdated extends AuthEvent {
  final User user;
  UserUpdated(this.user);
}

/// Relit le compte (quota de l'assistant, offre Pro).
class UserRefreshRequested extends AuthEvent {}
