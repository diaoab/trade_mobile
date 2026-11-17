import 'package:financial_ai_advisor/core/theme/app_theme.dart';
import 'package:financial_ai_advisor/core/widgets/app_champ_texte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget ecran(Widget champ) => MaterialApp(theme: AppTheme.light(), home: Scaffold(body: champ));

  bool masque(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).obscureText;

  testWidgets('l’œil affiche puis masque le mot de passe', (tester) async {
    await tester.pumpWidget(ecran(AppChampTexte(libelle: 'Mot de passe', controller: TextEditingController(), motDePasse: true)));

    expect(masque(tester), isTrue);

    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(masque(tester), isFalse);

    await tester.tap(find.byTooltip('Masquer le mot de passe'));
    await tester.pump();
    expect(masque(tester), isTrue);
  });

  testWidgets('pas d’œil sur un champ ordinaire', (tester) async {
    await tester.pumpWidget(ecran(AppChampTexte(libelle: 'E-mail', controller: TextEditingController())));
    expect(find.byType(IconButton), findsNothing);
    expect(masque(tester), isFalse);
  });
}
