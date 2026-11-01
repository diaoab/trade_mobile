import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String motDePasse);
  Future<Either<Failure, User>> register(String email, String motDePasse);

  /// Compte de la session enregistrée ; [SessionFailure] s'il n'y en a pas.
  Future<Either<Failure, User>> utilisateurCourant();

  /// Ferme la session côté serveur (au mieux) et efface les jetons.
  Future<void> logout();
}
