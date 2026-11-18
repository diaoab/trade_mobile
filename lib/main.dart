import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/routes/app_router.dart';
import 'core/services/auth_event_bus.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Compte connecté avec un mot de passe provisoire à remplacer.
bool _provisoire(AuthState s) => s is Authenticated && s.user.doitChangerMotDePasse;

class _MyAppState extends State<MyApp> {
  final _navigatorKey = AppRouter.navigatorKey;

  @override
  void initState() {
    super.initState();
    // Déconnexion forcée depuis l'intercepteur Dio (session refusée, compte désactivé).
    AuthEventBus.instance.onLogout.listen((message) => di.sl<AuthBloc>().add(SessionExpired(message: message)));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthBloc>()..add(AppStarted())),
        BlocProvider.value(value: di.sl<FavoritesBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Financial AI Advisor',
        theme: AppTheme.theme(),
        themeMode: ThemeMode.dark,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Agrandissement du texte du téléphone respecté jusqu'à 1,5.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (avant, apres) =>
                apres is! AuthLoading && (avant.runtimeType != apres.runtimeType || _provisoire(avant) != _provisoire(apres)),
            listener: (context, state) {
              di.sl<FavoritesBloc>().add(state is Authenticated ? LoadFavoris() : ViderFavoris());
              final route = _provisoire(state)
                  ? AppRouter.motDePasseProvisoireRoute
                  : state is Authenticated || state is Invite
                      ? AppRouter.homeRoute
                      : AppRouter.loginRoute;
              _navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
            },
            // Fond sombre partout : icônes de la barre d'état en clair.
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: MediaQuery(
                data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.5)),
                child: child!,
              ),
            ),
          );
        },
        initialRoute: AppRouter.splashRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
