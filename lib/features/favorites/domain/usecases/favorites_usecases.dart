import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/favorites_repository.dart';

class GetFavoris {
  final FavoritesRepository repository;
  GetFavoris(this.repository);

  Future<Either<Failure, List<String>>> call() => repository.getFavoris();
}

/// Ajoute ([suivre] vrai) ou retire un titre des favoris.
class ChangerFavori {
  final FavoritesRepository repository;
  ChangerFavori(this.repository);

  Future<Either<Failure, List<String>>> call(String symbol, {required bool suivre}) =>
      suivre ? repository.ajouter(symbol) : repository.retirer(symbol);
}
