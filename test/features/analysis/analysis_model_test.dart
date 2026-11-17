import 'package:financial_ai_advisor/features/analysis/data/models/analysis_model.dart';
import 'package:financial_ai_advisor/features/analysis/domain/entities/analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("lit la réponse de /structures/{symbol}/analysis", () {
    final a = AnalysisModel.fromJson({
      'symbol': 'PALM_CI',
      'name': 'PALM CI',
      'close': 7500,
      'pct': -1.2,
      'session_date': '2026-10-30',
      'result': {
        'decision': 'CONSERVER',
        'score': 52.4,
        'session_score': 40,
        'session_decision': 'VENDRE',
        'confidence': 61,
        'technical_score': 55,
        'ml_score': null,
        'risk_score': null,
        'positive': 2,
        'negative': 1,
        'neutral': 3,
        'reasons': [],
        'liquidity_warnings': ['Volume faible'],
        'details': [
          {'indicator': 'RSI', 'tone': 'negative', 'counted': true, 'text': 'Survente'},
          {'indicator': 'Volatilité', 'tone': 'neutral', 'counted': false, 'text': 'Modérée'},
        ],
      },
      'ml': {'probability_up': 0.41, 'counted': false, 'horizon_days': 60},
      'dividend': {'cutoff': '2026-11-10', 'ex_date': '2026-11-12', 'amount': 450, 'days_left': 9},
      'narration': [],
      'chart': {
        'dates': ['2026-10-29', '2026-10-30'],
        'Close': [7600, 7500],
        'MM20': [null, 7550.5],
      },
      'indicators': [],
    });

    expect(a.cours, 7500);
    expect(a.resultat.details.first.ton, Ton.negatif);
    expect(a.resultat.details.last.compte, isFalse);
    expect(a.resultat.alertesLiquidite, ['Volume faible']);
    expect(a.resultat.scoreSeance, 40);
    expect(a.resultat.decisionSeance, 'VENDRE');
    expect(a.prediction.horizonJours, 60);
    expect(a.dividende!.joursRestants, 9);
    expect(a.graphique['MM20'], [null, 7550.5]);
    expect(a.graphique['Absent'], isEmpty);
  });
}
