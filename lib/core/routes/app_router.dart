import 'package:flutter/material.dart';

import '../../features/analysis/presentation/pages/analysis_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/mot_de_passe_provisoire_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  AppRouter._();

  /// Clé du Navigator racine : la déconnexion forcée (intercepteur Dio)
  /// navigue sans BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';

  /// Première connexion avec un mot de passe provisoire.
  static const String motDePasseProvisoireRoute = '/mot-de-passe-provisoire';

  /// Argument facultatif : adresse déjà saisie (String).
  static const String resetPasswordRoute = '/mot-de-passe-oublie';

  /// Argument : symbole du titre (String).
  static const String analyseRoute = '/analyse';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return _sansAnimation(settings, const LoginPage());
      case resetPasswordRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => ResetPasswordPage(email: settings.arguments as String? ?? ''));
      case motDePasseProvisoireRoute:
        return _sansAnimation(settings, const MotDePasseProvisoirePage());
      case homeRoute:
        return _sansAnimation(settings, const HomePage());
      case analyseRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => AnalysisPage(symbol: settings.arguments as String));
      default:
        return _sansAnimation(settings, const SplashScreen());
    }
  }

  static Route<dynamic> _sansAnimation(RouteSettings settings, Widget page) =>
      PageRouteBuilder(settings: settings, pageBuilder: (_, _, _) => page, transitionDuration: Duration.zero);
}
