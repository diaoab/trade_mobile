import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/account_repository.dart';

class DeleteAccount {
  final AccountRepository repository;
  DeleteAccount(this.repository);

  Future<Either<Failure, void>> call() => repository.supprimerCompte();
}
