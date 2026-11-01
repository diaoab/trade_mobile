import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../errors/failure.dart';

/// Les réponses de l'API ont la forme { success, message, data } : on ne
/// garde que `data`.
T donnees<T>(Response<dynamic> response) => response.data['data'] as T;

/// Traduit une erreur Dio en exception au message lisible.
ServerException versException(DioException e) {
  final corps = e.response?.data;
  if (corps is Map && corps['message'] is String) {
    var message = corps['message'] as String;
    final details = corps['details'];
    if (details is List && details.isNotEmpty) message += ' : ${details.join(' · ')}';
    return ServerException(message, statusCode: e.response?.statusCode);
  }
  if (e.response?.statusCode == 429) {
    return const ServerException('Trop de requêtes : patiente quelques minutes.', statusCode: 429);
  }
  if (e.response == null) {
    return const ServerException('Serveur injoignable : vérifie ta connexion.');
  }
  return ServerException('Une erreur est survenue.', statusCode: e.response?.statusCode);
}

/// Exécute un appel de datasource et renvoie l'échec sous forme de [Failure].
/// Utilisé par tous les repositories.
Future<Either<Failure, T>> appelApi<T>(Future<T> Function() appel) async {
  try {
    return Right(await appel());
  } on DioException catch (e) {
    final exception = versException(e);
    if (exception.statusCode == 401) return const Left(SessionFailure());
    return Left(ServerFailure(errorMessage: exception.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(errorMessage: e.message));
  } catch (e) {
    return Left(ServerFailure(errorMessage: 'Réponse inattendue : $e'));
  }
}
