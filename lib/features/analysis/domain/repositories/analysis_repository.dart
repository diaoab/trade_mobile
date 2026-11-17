import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/analysis.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, Analysis>> getAnalysis(String symbol);

  /// Réponse de l'assistant morceau par morceau ; un échec arrête le flux.
  Stream<Either<Failure, EvenementAssistant>> demander(String symbol, List<MessageAssistant> messages);
}
