import '../../domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? erreur;

  /// Ouvrir la page sur la création de compte plutôt que la connexion.
  final bool creation;
  Unauthenticated({this.erreur, this.creation = false});
}

/// Visiteur sans compte : démo du Marché et de l'Analyse, en lecture seule.
class Invite extends AuthState {}
