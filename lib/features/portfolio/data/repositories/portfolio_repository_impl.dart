import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_remote_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  PortfolioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Portfolio>> getPortfolio() => appelApi(remoteDataSource.getPortfolio);

  @override
  Future<Either<Failure, Portfolio>> ajouter(NouvellePosition position) => appelApi(() => remoteDataSource.ajouter(position));

  @override
  Future<Either<Failure, Portfolio>> supprimer(int id) => appelApi(() => remoteDataSource.supprimer(id));
}
