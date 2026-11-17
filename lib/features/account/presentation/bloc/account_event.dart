import '../../domain/entities/preferences.dart';

abstract class AccountEvent {}

class LoadPreferences extends AccountEvent {}

class PreferencesChanged extends AccountEvent {
  final ModificationPreferences modification;
  PreferencesChanged(this.modification);
}

class ChangePasswordEvent extends AccountEvent {
  final String actuel;
  final String nouveau;
  ChangePasswordEvent({required this.actuel, required this.nouveau});
}

class DeleteAccountEvent extends AccountEvent {}

class ProfileChanged extends AccountEvent {
  final String prenom;
  final String nom;
  final String telephone;
  ProfileChanged({required this.prenom, required this.nom, required this.telephone});
}
