import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/offre.dart';

abstract class BillingRepository {
  Future<Either<Failure, Offre>> getOffre();
  Future<Either<Failure, Facture>> ouvrirFacture(String urlRetour);
  Future<Either<Failure, String>> confirmer(String jeton);
}
