import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/account_repository.dart';

class UpdateProfile {
  final AccountRepository repository;
  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call({required String prenom, required String nom, required String telephone}) =>
      repository.modifierProfil(prenom: prenom, nom: nom, telephone: telephone);
}
