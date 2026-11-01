import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/market_entry.dart';
import '../repositories/market_repository.dart';

class GetStructures {
  final MarketRepository repository;
  GetStructures(this.repository);

  Future<Either<Failure, List<MarketEntry>>> call() => repository.getStructures();
}
