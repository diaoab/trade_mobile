import 'package:financial_ai_advisor/features/analysis/domain/entities/simulation_achat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2 % l'aller-retour : 1 % à l'achat, 1 % à la vente.
  const sim = SimulationAchat(budget: 500000, cours: 8100, fraisAllerRetour: 2, dividendeParAction: 500);

  test('actions entières, frais d’achat compris dans le budget', () {
    // 8 100 × 1,01 = 8 181 par action : 61 actions.
    expect(sim.quantite, 61);
    expect(sim.montantTitres, 61 * 8100);
    expect(sim.fraisAchat, closeTo(61 * 8100 * 0.01, 0.001));
    expect(sim.totalDebourse, lessThanOrEqualTo(500000));
    expect(sim.reste, closeTo(500000 - sim.totalDebourse, 0.001));
    expect(sim.dividende, 61 * 500);
  });

  test('cours d’équilibre : revendre à ce cours ne perd rien', () {
    expect(sim.hausseEquilibre, closeTo((1.01 / 0.99 - 1) * 100, 1e-9));
    final variation = sim.hausseEquilibre;
    expect(sim.resultatSi(variation), closeTo(0, 1e-6));
  });

  test('cours inchangé : on perd les frais d’achat et de vente', () {
    expect(sim.resultatSi(0), closeTo(-(sim.fraisAchat + sim.montantTitres * 0.01), 1e-6));
    expect(sim.resultatSi(10), greaterThan(0));
    expect(sim.resultatSi(-10), lessThan(0));
  });

  test('budget insuffisant pour une action', () {
    const petit = SimulationAchat(budget: 5000, cours: 8100, fraisAllerRetour: 2);
    expect(petit.quantite, 0);
    expect(petit.dividende, isNull);
  });
}
