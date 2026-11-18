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
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyResetCode = '/auth/verify-reset-code';
  static const String authResetPassword = '/auth/reset-password';

  // ─── Compte ────────────────────────────────────────────────────────────
  static const String accountMe = '/account/me';
  static const String accountPreferences = '/account/preferences';

  // ─── Marché ────────────────────────────────────────────────────────────
  static const String market = '/market';
  static const String marketRefresh = '/market/refresh';
  // Mode démo (sans compte) : lecture seule, réglages par défaut.
  static const String demoMarket = '/demo/market';
  static String demoAnalyse(String symbol) => '/demo/structures/$symbol/analysis';
  static const String alertes = '/alerts';
  static const String favoris = '/account/favorites';
  static String favori(String symbol) => '/account/favorites/$symbol';
  static const String alertesLues = '/alerts/seen';
  static const String structures = '/structures';
  static String analyse(String symbol) => '/structures/$symbol/analysis';
  /// Réponse de l'assistant en Server-Sent Events (texte affiché pendant qu'il s'écrit).
  static String assistantFlux(String symbol) => '/structures/$symbol/assistant/stream';

  // ─── Portefeuille ──────────────────────────────────────────────────────
  static const String portfolio = '/portfolio';
  static const String positions = '/portfolio/positions';
  static String position(int id) => '/portfolio/positions/$id';

  // ─── Abonnement ────────────────────────────────────────────────────────
  static const String billingOffer = '/billing/offer';
  static const String billingCheckout = '/billing/checkout';
  static const String billingConfirm = '/billing/confirm';
}
