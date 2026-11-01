import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/market_entry.dart';
import '../repositories/market_repository.dart';

class GetMarket {
  final MarketRepository repository;
  GetMarket(this.repository);

  Future<Either<Failure, List<MarketEntry>>> call() => repository.getMarket();
}
