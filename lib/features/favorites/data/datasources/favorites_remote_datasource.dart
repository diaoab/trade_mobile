import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<String>> getFavoris();
  Future<List<String>> ajouter(String symbol);
  Future<List<String>> retirer(String symbol);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio dio;
  FavoritesRemoteDataSourceImpl({required this.dio});

  List<String> _liste(Response<dynamic> r) => donnees<List<dynamic>>(r).cast<String>();

  @override
  Future<List<String>> getFavoris() async => _liste(await dio.get(Env.favoris));

  @override
  Future<List<String>> ajouter(String symbol) async => _liste(await dio.put(Env.favori(symbol)));

  @override
  Future<List<String>> retirer(String symbol) async => _liste(await dio.delete(Env.favori(symbol)));
}
