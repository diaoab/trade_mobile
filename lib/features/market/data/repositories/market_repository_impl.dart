import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/market_entry.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_datasource.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;
  MarketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MarketEntry>>> getMarket() => appelApi(remoteDataSource.getMarket);

  @override
  Future<Either<Failure, List<MarketEntry>>> getStructures() => appelApi(remoteDataSource.getStructures);
}
