import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/config/env.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/etag_interceptor.dart';
import 'core/services/token_service.dart';

// Account
import 'features/account/data/datasources/account_remote_datasource.dart';
import 'features/account/data/repositories/account_repository_impl.dart';
import 'features/account/domain/repositories/account_repository.dart';
import 'features/account/domain/usecases/change_password.dart';
import 'features/account/domain/usecases/delete_account.dart';
import 'features/account/domain/usecases/get_preferences.dart';
import 'features/account/domain/usecases/update_preferences.dart';
import 'features/account/domain/usecases/update_profile.dart';
import 'features/account/presentation/bloc/account_bloc.dart';

// Analysis
import 'features/analysis/data/datasources/analysis_remote_datasource.dart';
import 'features/analysis/data/repositories/analysis_repository_impl.dart';
import 'features/analysis/domain/repositories/analysis_repository.dart';
import 'features/analysis/domain/usecases/ask_assistant.dart';
import 'features/analysis/domain/usecases/get_analysis.dart';
import 'features/analysis/presentation/bloc/analysis_bloc.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/reset_password.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/reset_password_bloc.dart';

// Billing
import 'features/billing/data/datasources/billing_remote_datasource.dart';
import 'features/billing/data/repositories/billing_repository_impl.dart';
import 'features/billing/domain/repositories/billing_repository.dart';
import 'features/billing/domain/usecases/confirm_payment.dart';
import 'features/billing/domain/usecases/get_offre.dart';
import 'features/billing/domain/usecases/start_checkout.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';

import 'features/onboarding/data/prise_en_main_service.dart';
// Favoris
import 'features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/favorites_usecases.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
// Alertes
import 'features/alerts/data/datasources/alerts_remote_datasource.dart';
import 'features/alerts/data/repositories/alerts_repository_impl.dart';
import 'features/alerts/domain/repositories/alerts_repository.dart';
import 'features/alerts/domain/usecases/alerts_usecases.dart';
import 'features/alerts/presentation/bloc/alerts_bloc.dart';
// Market
import 'features/market/data/datasources/market_remote_datasource.dart';
import 'features/market/data/repositories/market_repository_impl.dart';
import 'features/market/domain/repositories/market_repository.dart';
import 'features/market/domain/usecases/get_market.dart';
import 'features/market/domain/usecases/get_structures.dart';
import 'features/market/presentation/bloc/market_bloc.dart';

// Portfolio
import 'features/portfolio/data/datasources/portfolio_remote_datasource.dart';
import 'features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'features/portfolio/domain/repositories/portfolio_repository.dart';
import 'features/portfolio/domain/usecases/add_position.dart';
import 'features/portfolio/domain/usecases/delete_position.dart';
import 'features/portfolio/domain/usecases/get_portfolio.dart';
import 'features/portfolio/presentation/bloc/portfolio_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //================================================
  // CORE
  //================================================

  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenService(secureStorage: sl()));
  sl.registerLazySingleton(() => PriseEnMainService(secureStorage: sl()));
  sl.registerLazySingleton(() => EtagInterceptor());

  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: '${Env.baseUrl}${Env.apiPrefix}',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      headers: {'Accept': 'application/json'},
    ));
    dio.interceptors
      ..add(AuthInterceptor(dio: dio, tokenService: sl()))
      ..add(sl<EtagInterceptor>());
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false, logPrint: (o) => debugPrint('$o')));
    }
    return dio;
  });

  //================================================
  // AUTH
  //================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), tokenService: sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => AuthBloc(loginUser: sl(), registerUser: sl(), getCurrentUser: sl(), logoutUser: sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerFactory(() => ResetPasswordBloc(resetPassword: sl()));

  //================================================
  // MARCHÉ
  //================================================

  sl.registerLazySingleton<MarketRemoteDataSource>(() => MarketRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<MarketRepository>(() => MarketRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetMarket(sl()));
  sl.registerLazySingleton(() => GetStructures(sl()));
  sl.registerFactory(() => MarketBloc(getMarket: sl()));

  //================================================
  // FAVORIS (partagés par toute l'app : un seul bloc)
  //================================================

  sl.registerLazySingleton<FavoritesRemoteDataSource>(() => FavoritesRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetFavoris(sl()));
  sl.registerLazySingleton(() => ChangerFavori(sl()));
  sl.registerLazySingleton(() => FavoritesBloc(getFavoris: sl(), changerFavori: sl()));

  //================================================
  // ALERTES
  //================================================

  sl.registerLazySingleton<AlertsRemoteDataSource>(() => AlertsRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AlertsRepository>(() => AlertsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetAlertes(sl()));
  sl.registerLazySingleton(() => MarquerAlertesLues(sl()));
  sl.registerFactory(() => AlertsBloc(getAlertes: sl(), marquerLues: sl()));

  //================================================
  // ANALYSE D'UN TITRE
  //================================================

  sl.registerLazySingleton<AnalysisRemoteDataSource>(() => AnalysisRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AnalysisRepository>(() => AnalysisRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetAnalysis(sl()));
  sl.registerLazySingleton(() => AskAssistant(sl()));
  // Un bloc par écran d'analyse.
  sl.registerFactory(() => AnalysisBloc(getAnalysis: sl()));

  //================================================
  // PORTEFEUILLE
  //================================================

  sl.registerLazySingleton<PortfolioRemoteDataSource>(() => PortfolioRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<PortfolioRepository>(() => PortfolioRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetPortfolio(sl()));
  sl.registerLazySingleton(() => AddPosition(sl()));
  sl.registerLazySingleton(() => DeletePosition(sl()));
  sl.registerFactory(() => PortfolioBloc(getPortfolio: sl(), addPosition: sl(), deletePosition: sl()));

  //================================================
  // COMPTE
  //================================================

  sl.registerLazySingleton<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(remoteDataSource: sl(), tokenService: sl()));
  sl.registerLazySingleton(() => GetPreferences(sl()));
  sl.registerLazySingleton(() => UpdatePreferences(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerFactory(() => AccountBloc(
        getPreferences: sl(),
        updatePreferences: sl(),
        changePassword: sl(),
        deleteAccount: sl(),
        updateProfile: sl(),
      ));

  //================================================
  // ABONNEMENT
  //================================================

  sl.registerLazySingleton<BillingRemoteDataSource>(() => BillingRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<BillingRepository>(() => BillingRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetOffre(sl()));
  sl.registerLazySingleton(() => StartCheckout(sl()));
  sl.registerLazySingleton(() => ConfirmPayment(sl()));
  sl.registerFactory(() => BillingBloc(getOffre: sl(), startCheckout: sl(), confirmPayment: sl()));
}
