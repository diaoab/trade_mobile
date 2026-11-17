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

  /// Mot de passe oublié : code envoyé par e-mail, vérifié, puis nouveau
  /// mot de passe (toutes les sessions sont fermées, il faut se reconnecter).
  Future<Either<Failure, void>> demanderCode(String email);
  Future<Either<Failure, void>> verifierCode(String email, String code);
  Future<Either<Failure, void>> reinitialiser(String email, String code, String nouveau);
}
