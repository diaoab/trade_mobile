import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/portfolio.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, Portfolio>> getPortfolio();
  Future<Either<Failure, Portfolio>> ajouter(NouvellePosition position);
  Future<Either<Failure, Portfolio>> supprimer(int id);
}
