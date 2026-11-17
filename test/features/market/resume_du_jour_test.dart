import 'package:financial_ai_advisor/features/market/data/models/market_entry_model.dart';
import 'package:financial_ai_advisor/features/market/domain/entities/market_entry.dart';
import 'package:financial_ai_advisor/features/market/domain/entities/resume_du_jour.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/entities/portfolio.dart';
import 'package:flutter_test/flutter_test.dart';

MarketEntry titre(
  String symbol, {
  String? decision,
  String? avant,
  double? variation,
  Dividende? dividende,
  String date = '2026-11-16',
}) =>
    MarketEntry(
      symbol: symbol,
      nom: symbol.replaceAll('_', ' '),
      cours: 1000,
      variation: variation,
      date: date,
      decision: decision,
      decisionPrecedente: avant,
      dividende: dividende,
    );

Position position(String symbol, double valeur, {String dateCours = '2026-11-16'}) => Position(
      id: 1,
      symbol: symbol,
      nom: symbol,
      quantite: 10,
      prixAchat: 100,
      dateAchat: '2026-01-05',
      dateCours: dateCours,
      valorisation: Valorisation(cout: 1000, valeur: valeur, dividendes: 0, frais: 0, net: 0, netPct: 0),
    );

Portfolio portefeuille(List<Position> positions) => Portfolio(
      positions: positions,
      totaux: const TotauxPortefeuille(cout: 0, valeur: 0, dividendes: 0, frais: 0, net: 0),
    );

void main() {
  test('lit le signal de la séance précédente', () {
    final t = MarketEntryModel.fromJson({
      'symbol': 'PALM_CI',
      'name': 'PALM CI',
      'close': 8100,
      'decision': 'ACHETER',
      'previous_decision': 'CONSERVER',
    });
    expect(t.decisionPrecedente, 'CONSERVER');
  });

  test('ne retient que les signaux qui ont changé', () {
    final r = ResumeDuJour.calculer([
      titre('PALM_CI', decision: 'ACHETER', avant: 'CONSERVER'),
      titre('BIBI_CI', decision: 'VENDRE', avant: 'VENDRE'),
      titre('TOTAL_CI', decision: 'VENDRE'),
    ]);
    expect(r.bascules, [const BasculeSignal(symbol: 'PALM_CI', nom: 'PALM CI', avant: 'CONSERVER', apres: 'ACHETER')]);
    expect(r.portefeuille, isNull);
  });

  test('dividendes dans les 30 jours, du plus proche au plus lointain', () {
    Dividende div(int jours) =>
        Dividende(dateButoir: '2026-12-01', detachement: '2026-12-03', montant: 500, joursRestants: jours);
    final r = ResumeDuJour.calculer([
      titre('A', dividende: div(20)),
      titre('B', dividende: div(3)),
      titre('C', dividende: div(45)),
    ]);
    expect(r.dividendes.map((d) => d.symbol), ['B', 'A']);
  });

  test('variation du portefeuille sur la séance', () {
    // 11 000 aujourd'hui après +10 % : 10 000 la veille, soit +1 000.
    final r = ResumeDuJour.calculer(
      [titre('PALM_CI', variation: 10)],
      portfolio: portefeuille([position('PALM_CI', 11000)]),
    );
    expect(r.portefeuille!.montant, closeTo(1000, 0.01));
    expect(r.portefeuille!.pourcentage, closeTo(10, 0.01));
  });

  test('ignore une position valorisée à une autre séance que le titre', () {
    final r = ResumeDuJour.calculer(
      [titre('PALM_CI', variation: 10)],
      portfolio: portefeuille([position('PALM_CI', 11000, dateCours: '2026-11-13')]),
    );
    expect(r.portefeuille, isNull);
  });
}
