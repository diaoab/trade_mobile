import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/portfolio.dart';
import '../repositories/portfolio_repository.dart';

class GetPortfolio {
  final PortfolioRepository repository;
  GetPortfolio(this.repository);

  Future<Either<Failure, Portfolio>> call() => repository.getPortfolio();
}
