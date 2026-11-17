import 'package:financial_ai_advisor/core/theme/app_color.dart';
import 'package:financial_ai_advisor/core/utils/fraicheur.dart';
import 'package:financial_ai_advisor/core/widgets/bandeau_cours_anciens.dart';
import 'package:financial_ai_advisor/features/portfolio/data/models/portfolio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  // Mardi 17 novembre 2026.
  final mardi = DateTime(2026, 11, 17, 10);

  test('compte les séances (lundi-vendredi) écoulées', () {
    expect(Fraicheur.seancesDeRetard('2026-11-17', maintenant: mardi), 0);
    expect(Fraicheur.seancesDeRetard('2026-11-16', maintenant: mardi), 1);
    // Vendredi → mardi : lundi et mardi, le week-end ne compte pas.
    expect(Fraicheur.seancesDeRetard('2026-11-13', maintenant: mardi), 2);
    expect(Fraicheur.seancesDeRetard('2026-11-12', maintenant: mardi), 3);
    expect(Fraicheur.seancesDeRetard(null, maintenant: mardi), isNull);
    expect(Fraicheur.seancesDeRetard('n/a', maintenant: mardi), isNull);
  });

  test('ancien au-delà de 2 séances de retard', () {
    expect(Fraicheur.estAncienne('2026-11-13', maintenant: mardi), isFalse);
    expect(Fraicheur.estAncienne('2026-11-12', maintenant: mardi), isTrue);
    expect(Fraicheur.estAncienne('2025-12-31', maintenant: mardi), isTrue);
    expect(Fraicheur.estAncienne(null, maintenant: mardi), isFalse);
  });

  Widget ecran(Widget enfant) => MaterialApp(
        theme: ThemeData(extensions: const [AppColor.clair]),
        home: Scaffold(body: enfant),
      );

  testWidgets('le bandeau apparaît seulement si les cours sont anciens', (tester) async {
    await tester.pumpWidget(ecran(BandeauCoursAnciens(date: '2025-12-31', maintenant: mardi)));
    expect(find.text('Cours non à jour'), findsOneWidget);
    expect(find.textContaining('31 décembre 2025'), findsOneWidget);

    await tester.pumpWidget(ecran(BandeauCoursAnciens(date: '2026-11-16', maintenant: mardi)));
    expect(find.text('Cours non à jour'), findsNothing);
  });

  test('le portefeuille lit la date des cours utilisés', () {
    final p = PortfolioModel.fromJson({
      'positions': [
        {
          'id': 1,
          'symbol': 'PALM_CI',
          'name': 'PALM CI',
          'quantity': 10,
          'buy_price': 8000,
          'buy_date': '2025-06-02',
          'last_date': '2025-12-31',
          'valuation': null,
        },
      ],
      'totals': {'cost': 0, 'value': 0, 'dividends': 0, 'fees': 0, 'net': 0, 'net_pct': null, 'as_of': '2025-12-31'},
    });
    expect(p.positions.single.dateCours, '2025-12-31');
    expect(p.positions.single.enAttenteCours, isFalse);
    expect(p.totaux.dateCours, '2025-12-31');
    expect(p.totaux.enAttenteCours, 0);
  });

  test('un achat postérieur au dernier cours est en attente de cours', () {
    final p = PortfolioModel.fromJson({
      'positions': [
        {
          'id': 2,
          'symbol': 'BIBI_CI',
          'name': 'BIBI CI',
          'quantity': 100,
          'buy_price': 1500,
          'buy_date': '2026-11-17',
          'last_date': '2025-12-31',
          'awaiting_quote': true,
          'valuation': null,
        },
      ],
      'totals': {'cost': 0, 'value': 0, 'dividends': 0, 'fees': 0, 'net': 0, 'net_pct': null, 'as_of': null, 'awaiting_quote': 1},
    });
    expect(p.positions.single.enAttenteCours, isTrue);
    expect(p.positions.single.valorisation, isNull);
    expect(p.totaux.enAttenteCours, 1);
  });
}
