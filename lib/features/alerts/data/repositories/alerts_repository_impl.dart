import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/alerte.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_datasource.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final AlertsRemoteDataSource remoteDataSource;
  AlertsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Alertes>> getAlertes() => appelApi(remoteDataSource.getAlertes);

  @override
  Future<Either<Failure, Alertes>> marquerLues() => appelApi(remoteDataSource.marquerLues);
}
