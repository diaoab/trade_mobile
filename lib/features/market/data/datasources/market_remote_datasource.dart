import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../../../../core/services/mode_session.dart';
import '../models/market_entry_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<MarketEntryModel>> getMarket();

  /// Titres disponibles (sans calcul du signal), pour les listes de choix.
  Future<List<MarketEntryModel>> getStructures();

  /// Récupère les cours du jour (Sika Finance) : date de la dernière séance
  /// connue ensuite.
  Future<String?> rafraichirCours();
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final Dio dio;
  MarketRemoteDataSourceImpl({required this.dio});

  List<MarketEntryModel> _liste(Response<dynamic> r) =>
      donnees<List<dynamic>>(r).map((e) => MarketEntryModel.fromJson(e as Map<String, dynamic>)).toList();

  @override
  Future<List<MarketEntryModel>> getMarket() async =>
      _liste(await dio.get(ModeSession.instance.invite ? Env.demoMarket : Env.market));

  @override
  Future<List<MarketEntryModel>> getStructures() async => _liste(await dio.get(Env.structures));

  @override
  Future<String?> rafraichirCours() async =>
      donnees<Map<String, dynamic>>(await dio.post(Env.marketRefresh))['date'] as String?;
}
