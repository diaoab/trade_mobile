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

/// Traduit une erreur d'appel en [Failure] (401 : session à reprendre).
Failure versFailure(Object erreur) {
  final exception = switch (erreur) {
    DioException e => versException(e),
    ServerException e => e,
    _ => null,
  };
  if (exception == null) return ServerFailure(errorMessage: 'Réponse inattendue : $erreur');
  if (exception.statusCode == 401) return const SessionFailure();
  return ServerFailure(errorMessage: exception.message);
}

/// Exécute un appel de datasource et renvoie l'échec sous forme de [Failure].
/// Utilisé par tous les repositories.
Future<Either<Failure, T>> appelApi<T>(Future<T> Function() appel) async {
  try {
    return Right(await appel());
  } catch (e) {
    return Left(versFailure(e));
  }
}

/// Comme [appelApi], pour une réponse en flux : chaque élément en [Right],
/// puis l'échec éventuel en [Left] (le flux s'arrête alors).
Stream<Either<Failure, T>> fluxApi<T>(Stream<T> Function() appel) async* {
  try {
    await for (final element in appel()) {
      yield Right(element);
    }
  } catch (e) {
    yield Left(versFailure(e));
  }
}
