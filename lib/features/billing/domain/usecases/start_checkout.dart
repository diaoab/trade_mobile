import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/offre.dart';
import '../repositories/billing_repository.dart';

/// Ouvre une facture PayDunya ; le client paie dans le navigateur.
class StartCheckout {
  final BillingRepository repository;
  StartCheckout(this.repository);

  Future<Either<Failure, Facture>> call(String urlRetour) => repository.ouvrirFacture(urlRetour);
}
