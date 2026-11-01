import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/analysis.dart';
import '../repositories/analysis_repository.dart';

class GetAnalysis {
  final AnalysisRepository repository;
  GetAnalysis(this.repository);

  Future<Either<Failure, Analysis>> call(String symbol) => repository.getAnalysis(symbol);
}
