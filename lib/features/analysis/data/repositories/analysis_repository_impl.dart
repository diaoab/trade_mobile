import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/analysis.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_datasource.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDataSource remoteDataSource;
  AnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Analysis>> getAnalysis(String symbol) => appelApi(() => remoteDataSource.getAnalysis(symbol));

  @override
  Stream<Either<Failure, EvenementAssistant>> demander(String symbol, List<MessageAssistant> messages) =>
      fluxApi(() => remoteDataSource.demander(symbol, messages));
}
