import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_call.dart';
import '../../../../core/network/sse.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/analysis.dart';
import '../models/analysis_model.dart';

abstract class AnalysisRemoteDataSource {
  Future<AnalysisModel> getAnalysis(String symbol);

  /// Réponse à la dernière question de [messages], morceau par morceau.
  Stream<EvenementAssistant> demander(String symbol, List<MessageAssistant> messages);
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final Dio dio;
  AnalysisRemoteDataSourceImpl({required this.dio});

  @override
  Future<AnalysisModel> getAnalysis(String symbol) async =>
      AnalysisModel.fromJson(donnees(await dio.get(Env.analyse(symbol))));

  /// L'API répond en Server-Sent Events :
  ///   delta {"text"}       morceau de la réponse (autant que nécessaire)
  ///   done  {"assistant"}  quota du jour, en fin de réponse
  ///   error {"message"}    à la place de done
  /// Une demande refusée (quota atteint, conversation invalide) part en JSON
  /// habituel, avant le flux.
  @override
  Stream<EvenementAssistant> demander(String symbol, List<MessageAssistant> messages) async* {
    final Response<ResponseBody> reponse;
    try {
      reponse = await dio.post<ResponseBody>(
        Env.assistantFlux(symbol),
        data: {'messages': messages.map((m) => m.toJson()).toList()},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
          // Délai entre deux morceaux : la réponse complète peut prendre plus longtemps.
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
    } on DioException catch (e) {
      throw await _avecCorpsLu(e);
    }

    await for (final evenement in lireSse(reponse.data!.stream)) {
      final donnees = evenement.donnees as Map<String, dynamic>;
      switch (evenement.nom) {
        case 'delta':
          yield MorceauAssistant(donnees['text'] as String);
        case 'done':
          yield FinAssistant(QuotaModel.fromJson(donnees['assistant'] as Map<String, dynamic>));
          return;
        case 'error':
          throw ServerException(donnees['message'] as String? ?? 'L’assistant n’a pas pu répondre.');
      }
    }
    throw const ServerException('La réponse de l’assistant a été interrompue. Réessaie.');
  }

  /// Erreur d'une requête en flux : le corps JSON (message de l'API) n'est
  /// pas encore lu. On le lit pour garder un message clair.
  Future<Object> _avecCorpsLu(DioException e) async {
    final corps = e.response?.data;
    if (corps is! ResponseBody) return e;
    try {
      final texte = await utf8.decoder.bind(corps.stream).join();
      return e.copyWith(
        response: Response(
          requestOptions: e.requestOptions,
          statusCode: e.response!.statusCode,
          headers: e.response!.headers,
          data: jsonDecode(texte),
        ),
      );
    } catch (_) {
      return e;
    }
  }
}
