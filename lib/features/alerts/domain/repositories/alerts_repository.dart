import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/alerte.dart';

abstract class AlertsRepository {
  Future<Either<Failure, Alertes>> getAlertes();
  Future<Either<Failure, Alertes>> marquerLues();
}
