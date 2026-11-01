import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../services/auth_event_bus.dart';
import '../services/token_service.dart';

/// Ajoute le jeton d'accès et le renouvelle sur un 401.
///
/// Un seul renouvellement à la fois : plusieurs écrans peuvent recevoir un
/// 401 en même temps, et l'API refuse un jeton de rafraîchissement déjà
/// utilisé (elle ferme alors toutes les sessions du compte).
///
/// Le renouvellement passe par un client Dio sans intercepteur : un 401 sur
/// /auth/refresh ne doit pas revenir ici.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenService tokenService;
  final Dio _sansIntercepteur;

  AuthInterceptor({required this.dio, required this.tokenService})
      : _sansIntercepteur = Dio(dio.options);

  static const skip = 'skipAuthInterceptor';

  // Un 401 sur ces routes est une vraie erreur (mauvais mot de passe…),
  // pas un jeton expiré.
  static const _publics = {Env.login, Env.register, Env.authRefresh, Env.authLogout};

  Future<String?>? _renouvellement;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[skip] != true) {
      final token = await tokenService.getToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final estPublic = options.extra[skip] == true || _publics.contains(options.path);

    if (err.response?.statusCode != 401 || estPublic || options.extra['retried'] == true) {
      return handler.next(err);
    }

    final envoye = options.headers['Authorization'];
    final actuel = await tokenService.getToken();

    // Une autre requête a déjà renouvelé la session pendant l'attente.
    String? token = actuel != null && 'Bearer $actuel' != envoye ? actuel : null;
    token ??= await (_renouvellement ??= _renouveler().whenComplete(() => _renouvellement = null));

    if (token == null) {
      await tokenService.clear();
      AuthEventBus.instance.emitLogout();
      return handler.next(err);
    }

    try {
      options
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['retried'] = true;
      handler.resolve(await dio.fetch(options));
    } on DioException catch (erreur) {
      handler.next(erreur);
    }
  }

  Future<String?> _renouveler() async {
    final refreshToken = await tokenService.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final response = await _sansIntercepteur.post(
        Env.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      await tokenService.saveSession(
        token: data['token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return data['token'] as String;
    } catch (erreur) {
      if (kDebugMode) debugPrint('Renouvellement de session refusé : $erreur');
      return null;
    }
  }
}
