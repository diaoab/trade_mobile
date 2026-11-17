import 'package:financial_ai_advisor/core/theme/app_theme.dart';
import 'package:financial_ai_advisor/features/onboarding/presentation/pages/prise_en_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('quatre étapes, puis « Commencer » ferme et prévient l’appelant', (tester) async {
    var terminee = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => ouvrirPriseEnMain(context, onTerminee: () => terminee = true),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    expect(find.text('Un signal par titre'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Une aide, pas un conseil'), findsOneWidget);

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(find.text('ouvrir'), findsOneWidget);
    expect(terminee, isTrue);
  });

  testWidgets('« Passer » ferme dès la première étape', (tester) async {
    var terminee = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => ouvrirPriseEnMain(context, onTerminee: () => terminee = true),
          child: const Text('ouvrir'),
        ),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(terminee, isTrue);
  });
}
