import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/billing_repository.dart';

/// Vérifie la facture auprès de PayDunya (par l'API) : seul ce contrôle
/// active l'offre, jamais le retour du navigateur.
class ConfirmPayment {
  final BillingRepository repository;
  ConfirmPayment(this.repository);

  Future<Either<Failure, String>> call(String jeton) => repository.confirmer(jeton);
}
