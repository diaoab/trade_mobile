import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<String>>> getFavoris();
  Future<Either<Failure, List<String>>> ajouter(String symbol);
  Future<Either<Failure, List<String>>> retirer(String symbol);
}
