import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../models/alertes_model.dart';

abstract class AlertsRemoteDataSource {
  Future<AlertesModel> getAlertes();
  Future<AlertesModel> marquerLues();
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  final Dio dio;
  AlertsRemoteDataSourceImpl({required this.dio});

  @override
  Future<AlertesModel> getAlertes() async =>
      AlertesModel.fromJson(donnees<Map<String, dynamic>>(await dio.get(Env.alertes)));

  @override
  Future<AlertesModel> marquerLues() async =>
      AlertesModel.fromJson(donnees<Map<String, dynamic>>(await dio.post(Env.alertesLues)));
}
