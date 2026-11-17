import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../../../core/services/token_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/preferences.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final TokenService tokenService;

  AccountRepositoryImpl({required this.remoteDataSource, required this.tokenService});

  @override
  Future<Either<Failure, User>> modifierProfil({required String prenom, required String nom, required String telephone}) {
    String? valeur(String texte) => texte.trim().isEmpty ? null : texte.trim();
    return appelApi(() => remoteDataSource.modifierProfil(prenom: valeur(prenom), nom: valeur(nom), telephone: valeur(telephone)));
  }

  @override
  Future<Either<Failure, Preferences>> getPreferences() => appelApi(remoteDataSource.getPreferences);

  @override
  Future<Either<Failure, Preferences>> modifierPreferences(ModificationPreferences modification) =>
      appelApi(() => remoteDataSource.modifierPreferences(modification));

  @override
  Future<Either<Failure, void>> changerMotDePasse(String actuel, String nouveau) => appelApi(() async {
        final session = await remoteDataSource.changerMotDePasse(actuel, nouveau);
        await tokenService.saveSession(token: session.token, refreshToken: session.refreshToken);
      });

  @override
  Future<Either<Failure, void>> supprimerCompte() => appelApi(() async {
        await remoteDataSource.supprimerCompte();
        await tokenService.clear();
      });
}
