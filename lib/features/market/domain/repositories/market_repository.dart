import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/market_entry.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<MarketEntry>>> getMarket();
  Future<Either<Failure, List<MarketEntry>>> getStructures();
}
