import 'package:financial_ai_advisor/core/theme/app_theme.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_event.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_state.dart';
import 'package:financial_ai_advisor/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class _AuthBloc extends Mock implements AuthBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(ContinuerSansCompte());
    return initializeDateFormatting('fr_FR');
  });

  Future<_AuthBloc> ouvrir(WidgetTester tester, AuthState etat) async {
    final bloc = _AuthBloc();
    when(() => bloc.state).thenReturn(etat);
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: BlocProvider<AuthBloc>.value(value: bloc, child: const LoginPage()),
    ));
    return bloc;
  }

  testWidgets('« Découvrir sans compte » entre en démo', (tester) async {
    final bloc = await ouvrir(tester, Unauthenticated());
    await tester.tap(find.text('Découvrir sans compte'));
    verify(() => bloc.add(any(that: isA<ContinuerSansCompte>()))).called(1);
  });

  testWidgets('ouvre sur la création de compte quand elle est demandée', (tester) async {
    await ouvrir(tester, Unauthenticated(creation: true));
    expect(find.text('Créer mon compte'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsNothing);
  });

  testWidgets('la bascule passe de la connexion à la création', (tester) async {
    await ouvrir(tester, Unauthenticated());
    expect(find.text('Se connecter'), findsOneWidget);
    await tester.tap(find.text('Créer un compte'));
    await tester.pump();
    expect(find.text('Créer mon compte'), findsOneWidget);
  });
}
