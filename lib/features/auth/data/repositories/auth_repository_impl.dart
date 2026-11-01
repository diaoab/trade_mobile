import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenService tokenService;

  AuthRepositoryImpl({required this.remoteDataSource, required this.tokenService});

  Future<Either<Failure, User>> _ouvrir(Future<AuthResponseModel> Function() appel) => appelApi(() async {
        final reponse = await appel();
        await tokenService.saveSession(token: reponse.token, refreshToken: reponse.refreshToken);
        return reponse.user;
      });

  @override
  Future<Either<Failure, User>> login(String email, String motDePasse) =>
      _ouvrir(() => remoteDataSource.login(email, motDePasse));

  @override
  Future<Either<Failure, User>> register(String email, String motDePasse) =>
      _ouvrir(() => remoteDataSource.register(email, motDePasse));

  @override
  Future<Either<Failure, User>> utilisateurCourant() async {
    if (!await tokenService.hasSession) return const Left(SessionFailure());
    return appelApi(remoteDataSource.me);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenService.getRefreshToken();
    // Sans réseau, on se déconnecte quand même : la session expirera côté serveur.
    if (refreshToken != null) await appelApi(() => remoteDataSource.logout(refreshToken));
    await tokenService.clear();
  }
}
