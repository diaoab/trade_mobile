import '../../../auth/data/models/user_model.dart';
import '../../../market/data/models/market_entry_model.dart';
import '../../domain/entities/analysis.dart';

class AnalysisModel extends Analysis {
  const AnalysisModel({
    required super.symbol,
    required super.nom,
    required super.cours,
    super.variation,
    super.seance,
    required super.resultat,
    required super.prediction,
    super.dividende,
    required super.graphique,
  });

  static Ton _ton(Object? valeur) => switch (valeur) {
        'positive' => Ton.positif,
        'negative' => Ton.negatif,
        _ => Ton.neutre,
      };

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    final r = json['result'] as Map<String, dynamic>;
    final ml = json['ml'] as Map<String, dynamic>;
    final chart = json['chart'] as Map<String, dynamic>;
    return AnalysisModel(
      symbol: json['symbol'] as String,
      nom: json['name'] as String,
      cours: nombreOuNull(json['close']) ?? 0,
      variation: nombreOuNull(json['pct']),
      seance: json['session_date'] as String?,
      resultat: ResultatDecision(
        decision: r['decision'] as String? ?? '',
        score: nombreOuNull(r['score']) ?? 0,
        confiance: nombreOuNull(r['confidence']) ?? 0,
        scoreTechnique: nombreOuNull(r['technical_score']) ?? 0,
        scoreRisque: nombreOuNull(r['risk_score']),
        positifs: r['positive'] as int? ?? 0,
        negatifs: r['negative'] as int? ?? 0,
        neutres: r['neutral'] as int? ?? 0,
        alertesLiquidite: (r['liquidity_warnings'] as List?)?.cast<String>() ?? const [],
        details: [
          for (final d in (r['details'] as List? ?? const []).cast<Map<String, dynamic>>())
            DetailIndicateur(
              indicateur: d['indicator'] as String,
              ton: _ton(d['tone']),
              compte: d['counted'] as bool? ?? true,
              texte: d['text'] as String? ?? '',
            ),
        ],
      ),
      prediction: Prediction(
        probabiliteHausse: nombreOuNull(ml['probability_up']),
        compte: ml['counted'] as bool? ?? false,
        horizonJours: ml['horizon_days'] as int?,
      ),
      dividende: DividendeModel.fromJson(json['dividend']),
      graphique: SeriesGraphique(
        dates: (chart['dates'] as List? ?? const []).cast<String>(),
        series: {
          for (final e in chart.entries)
            if (e.key != 'dates') e.key: serie(e.value),
        },
      ),
    );
  }
}

class ReponseAssistantModel extends ReponseAssistant {
  const ReponseAssistantModel({required super.reponse, required super.quota});

  factory ReponseAssistantModel.fromJson(Map<String, dynamic> json) => ReponseAssistantModel(
        reponse: json['answer'] as String,
        quota: QuotaModel.fromJson(json['assistant'] as Map<String, dynamic>),
      );
}
