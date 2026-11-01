import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/preferences.dart';
import '../repositories/account_repository.dart';

class GetPreferences {
  final AccountRepository repository;
  GetPreferences(this.repository);

  Future<Either<Failure, Preferences>> call() => repository.getPreferences();
}
