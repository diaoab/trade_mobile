import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../models/market_entry_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<MarketEntryModel>> getMarket();

  /// Titres disponibles (sans calcul du signal), pour les listes de choix.
  Future<List<MarketEntryModel>> getStructures();
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final Dio dio;
  MarketRemoteDataSourceImpl({required this.dio});

  List<MarketEntryModel> _liste(Response<dynamic> r) =>
      donnees<List<dynamic>>(r).map((e) => MarketEntryModel.fromJson(e as Map<String, dynamic>)).toList();

  @override
  Future<List<MarketEntryModel>> getMarket() async => _liste(await dio.get(Env.market));

  @override
  Future<List<MarketEntryModel>> getStructures() async => _liste(await dio.get(Env.structures));
}
