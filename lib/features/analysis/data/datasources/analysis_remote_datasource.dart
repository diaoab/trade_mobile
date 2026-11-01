import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/analysis.dart';
import '../models/analysis_model.dart';

abstract class AnalysisRemoteDataSource {
  Future<AnalysisModel> getAnalysis(String symbol);
  Future<ReponseAssistantModel> demander(String symbol, List<MessageAssistant> messages);
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final Dio dio;
  AnalysisRemoteDataSourceImpl({required this.dio});

  @override
  Future<AnalysisModel> getAnalysis(String symbol) async =>
      AnalysisModel.fromJson(donnees(await dio.get(Env.analyse(symbol))));

  @override
  Future<ReponseAssistantModel> demander(String symbol, List<MessageAssistant> messages) async {
    final r = await dio.post(
      Env.assistant(symbol),
      data: {'messages': messages.map((m) => m.toJson()).toList()},
      // L'assistant (API Claude) peut mettre plus longtemps qu'un appel ordinaire.
      options: Options(receiveTimeout: const Duration(seconds: 90)),
    );
    return ReponseAssistantModel.fromJson(donnees(r));
  }
}
