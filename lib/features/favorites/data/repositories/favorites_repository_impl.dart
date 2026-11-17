import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;
  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<String>>> getFavoris() => appelApi(remoteDataSource.getFavoris);

  @override
  Future<Either<Failure, List<String>>> ajouter(String symbol) => appelApi(() => remoteDataSource.ajouter(symbol));

  @override
  Future<Either<Failure, List<String>>> retirer(String symbol) => appelApi(() => remoteDataSource.retirer(symbol));
}
