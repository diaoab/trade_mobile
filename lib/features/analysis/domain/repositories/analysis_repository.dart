import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/analysis.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, Analysis>> getAnalysis(String symbol);
  Future<Either<Failure, ReponseAssistant>> demander(String symbol, List<MessageAssistant> messages);
}
