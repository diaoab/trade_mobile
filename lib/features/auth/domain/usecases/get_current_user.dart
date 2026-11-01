import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Reprise de la session au démarrage, et relecture du compte (quota de
/// l'assistant, offre Pro) après une action qui le modifie.
class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<Either<Failure, User>> call() => repository.utilisateurCourant();
}
