import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/offre.dart';
import '../repositories/billing_repository.dart';

class GetOffre {
  final BillingRepository repository;
  GetOffre(this.repository);

  Future<Either<Failure, Offre>> call() => repository.getOffre();
}
