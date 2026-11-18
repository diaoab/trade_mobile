import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/market_entry.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<MarketEntry>>> getMarket();
  Future<Either<Failure, List<MarketEntry>>> getStructures();

  /// Cours du jour : date de la dernière séance connue ensuite.
  Future<Either<Failure, String?>> rafraichirCours();
}
