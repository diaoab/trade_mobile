import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/preferences.dart';

abstract class AccountRepository {
  Future<Either<Failure, Preferences>> getPreferences();
  Future<Either<Failure, Preferences>> modifierPreferences(ModificationPreferences modification);
  Future<Either<Failure, void>> changerMotDePasse(String actuel, String nouveau);
  Future<Either<Failure, void>> supprimerCompte();
}
