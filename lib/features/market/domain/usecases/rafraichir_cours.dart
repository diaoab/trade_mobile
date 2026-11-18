import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/market_repository.dart';

/// Bouton « Récupérer les cours du jour ».
class RafraichirCours {
  final MarketRepository repository;
  RafraichirCours(this.repository);

  Future<Either<Failure, String?>> call() => repository.rafraichirCours();
}
