import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/portfolio.dart';
import '../repositories/portfolio_repository.dart';

class AddPosition {
  final PortfolioRepository repository;
  AddPosition(this.repository);

  Future<Either<Failure, Portfolio>> call(NouvellePosition position) => repository.ajouter(position);
}
