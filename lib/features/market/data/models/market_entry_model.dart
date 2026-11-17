import '../../domain/entities/market_entry.dart';

double? nombreOuNull(Object? valeur) => valeur is num ? valeur.toDouble() : null;

List<double?> serie(Object? valeurs) => valeurs is List ? valeurs.map(nombreOuNull).toList() : const [];

class DividendeModel extends Dividende {
  const DividendeModel({required super.dateButoir, required super.detachement, required super.montant, required super.joursRestants});

  static DividendeModel? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return DividendeModel(
      dateButoir: json['cutoff'] as String,
      detachement: json['ex_date'] as String,
      montant: (json['amount'] as num).toDouble(),
      joursRestants: json['days_left'] as int,
    );
  }
}

class MarketEntryModel extends MarketEntry {
  const MarketEntryModel({
    required super.symbol,
    required super.nom,
    required super.cours,
    super.variation,
    super.date,
    super.decision,
    super.decisionPrecedente,
    super.score,
    super.changements,
    super.dividende,
    super.spark,
  });

  factory MarketEntryModel.fromJson(Map<String, dynamic> json) => MarketEntryModel(
        symbol: json['symbol'] as String,
        nom: json['name'] as String,
        cours: nombreOuNull(json['close']) ?? 0,
        variation: nombreOuNull(json['pct']),
        date: json['date'] as String?,
        decision: json['decision'] as String?,
        decisionPrecedente: json['previous_decision'] as String?,
        score: nombreOuNull(json['score']),
        changements: (json['changes'] as List?)?.cast<String>() ?? const [],
        dividende: DividendeModel.fromJson(json['dividend']),
        spark: serie(json['spark']),
      );
}
