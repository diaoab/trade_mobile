import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/preferences.dart';
import '../repositories/account_repository.dart';

class UpdatePreferences {
  final AccountRepository repository;
  UpdatePreferences(this.repository);

  Future<Either<Failure, Preferences>> call(ModificationPreferences modification) => repository.modifierPreferences(modification);
}
