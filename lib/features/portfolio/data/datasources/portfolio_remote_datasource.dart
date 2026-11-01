import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/portfolio.dart';
import '../models/portfolio_model.dart';

/// Chaque modification renvoie le portefeuille complet, revalorisé.
abstract class PortfolioRemoteDataSource {
  Future<PortfolioModel> getPortfolio();
  Future<PortfolioModel> ajouter(NouvellePosition position);
  Future<PortfolioModel> supprimer(int id);
}

class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  final Dio dio;
  PortfolioRemoteDataSourceImpl({required this.dio});

  PortfolioModel _lire(Response<dynamic> r) => PortfolioModel.fromJson(donnees(r));

  @override
  Future<PortfolioModel> getPortfolio() async => _lire(await dio.get(Env.portfolio));

  @override
  Future<PortfolioModel> ajouter(NouvellePosition position) async =>
      _lire(await dio.post(Env.positions, data: position.toJson()));

  @override
  Future<PortfolioModel> supprimer(int id) async => _lire(await dio.delete(Env.position(id)));
}
