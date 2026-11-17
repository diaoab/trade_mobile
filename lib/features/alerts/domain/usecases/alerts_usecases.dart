import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/alerte.dart';
import '../repositories/alerts_repository.dart';

class GetAlertes {
  final AlertsRepository repository;
  GetAlertes(this.repository);

  Future<Either<Failure, Alertes>> call() => repository.getAlertes();
}

class MarquerAlertesLues {
  final AlertsRepository repository;
  MarquerAlertesLues(this.repository);

  Future<Either<Failure, Alertes>> call() => repository.marquerLues();
}
