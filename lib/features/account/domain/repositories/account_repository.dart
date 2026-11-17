import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/preferences.dart';

abstract class AccountRepository {
  /// Prénom, nom et téléphone ; une valeur vide efface le champ.
  Future<Either<Failure, User>> modifierProfil({required String prenom, required String nom, required String telephone});
  Future<Either<Failure, Preferences>> getPreferences();
  Future<Either<Failure, Preferences>> modifierPreferences(ModificationPreferences modification);
  Future<Either<Failure, void>> changerMotDePasse(String actuel, String nouveau);
  Future<Either<Failure, void>> supprimerCompte();
}
