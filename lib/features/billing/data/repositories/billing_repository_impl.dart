import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/offre.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;
  BillingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Offre>> getOffre() => appelApi(remoteDataSource.getOffre);

  @override
  Future<Either<Failure, Facture>> ouvrirFacture(String urlRetour) => appelApi(() => remoteDataSource.ouvrirFacture(urlRetour));

  @override
  Future<Either<Failure, String>> confirmer(String jeton) => appelApi(() => remoteDataSource.confirmer(jeton));
}
