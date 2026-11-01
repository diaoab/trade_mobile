import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/portfolio.dart';
import '../repositories/portfolio_repository.dart';

class DeletePosition {
  final PortfolioRepository repository;
  DeletePosition(this.repository);

  Future<Either<Failure, Portfolio>> call(int id) => repository.supprimer(id);
}
