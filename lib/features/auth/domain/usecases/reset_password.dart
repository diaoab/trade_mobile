import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// Mot de passe oublié, en trois étapes : code par e-mail, vérification du
/// code, nouveau mot de passe.
class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);

  Future<Either<Failure, void>> demanderCode(String email) => repository.demanderCode(email);

  Future<Either<Failure, void>> verifierCode(String email, String code) => repository.verifierCode(email, code);

  Future<Either<Failure, void>> reinitialiser(String email, String code, String nouveau) =>
      repository.reinitialiser(email, code, nouveau);
}
