import 'dart:io';

import 'package:flutter/foundation.dart';

/// Résolution de l'adresse de l'API.
/// Priorité : 1) --dart-define (build de production)  2) valeur par défaut.
///
/// En production :
///   flutter build appbundle --dart-define=API_BASE_URL=https://api.exemple.com
class Env {
  Env._();

  static const String _fromDefine = String.fromEnvironment('API_BASE_URL');

  /// Adresse de l'API (trade_back), sans le préfixe /trade/v1.
  ///
  /// En développement, l'émulateur Android joint la machine hôte par
  /// 10.0.2.2 ; le simulateur iOS par localhost.
  static String get baseUrl {
    if (_fromDefine.isNotEmpty) return _fromDefine;
    if (kReleaseMode) return 'https://finadvisor-api.onrender.com';
    return Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
  }

  /// Toutes les routes métier sont versionnées sous ce préfixe (cf. trade_back).
  static const String apiPrefix = '/trade/v1';

  /// Schéma de l'app : PayDunya y renvoie le client après paiement
  /// (doit figurer dans APP_REDIRECT_PREFIXES côté API).
  static const String retourPaiement = 'finadvisor://compte';

  // ─── Auth ──────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authPassword = '/auth/password';

  // ─── Compte ────────────────────────────────────────────────────────────
  static const String accountMe = '/account/me';
  static const String accountPreferences = '/account/preferences';

  // ─── Marché ────────────────────────────────────────────────────────────
  static const String market = '/market';
  static const String structures = '/structures';
  static String analyse(String symbol) => '/structures/$symbol/analysis';
  static String assistant(String symbol) => '/structures/$symbol/assistant';

  // ─── Portefeuille ──────────────────────────────────────────────────────
  static const String portfolio = '/portfolio';
  static const String positions = '/portfolio/positions';
  static String position(int id) => '/portfolio/positions/$id';

  // ─── Abonnement ────────────────────────────────────────────────────────
  static const String billingOffer = '/billing/offer';
  static const String billingCheckout = '/billing/checkout';
  static const String billingConfirm = '/billing/confirm';
}
