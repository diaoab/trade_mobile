import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/account_repository.dart';

class ChangePassword {
  final AccountRepository repository;
  ChangePassword(this.repository);

  Future<Either<Failure, void>> call(String actuel, String nouveau) => repository.changerMotDePasse(actuel, nouveau);
}
