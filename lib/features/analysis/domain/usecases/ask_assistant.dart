import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/analysis.dart';
import '../repositories/analysis_repository.dart';

/// Question à l'assistant sur l'analyse d'un titre (quota quotidien selon
/// l'offre). La réponse arrive morceau par morceau.
class AskAssistant {
  final AnalysisRepository repository;
  AskAssistant(this.repository);

  Stream<Either<Failure, EvenementAssistant>> call(String symbol, List<MessageAssistant> messages) =>
      repository.demander(symbol, messages);
}
