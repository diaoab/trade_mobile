import 'package:equatable/equatable.dart';

/// Prochain dividende d'un titre : date butoir d'achat et détachement.
class Dividende extends Equatable {
  final String dateButoir;
  final String detachement;
  final double montant;
  final int joursRestants;

  const Dividende({required this.dateButoir, required this.detachement, required this.montant, required this.joursRestants});

  @override
  List<Object?> get props => [dateButoir, detachement, montant, joursRestants];
}

class MarketEntry extends Equatable {
  final String symbol;
  final String nom;
  final double cours;
  final double? variation;
  final String? date;
  final String? decision;
  final double? score;

  /// Changements notables depuis la séance précédente (« RSI en survente »…).
  final List<String> changements;
  final Dividende? dividende;

  /// Clôtures récentes, pour la mini-courbe.
  final List<double?> spark;

  const MarketEntry({
    required this.symbol,
    required this.nom,
    required this.cours,
    this.variation,
    this.date,
    this.decision,
    this.score,
    this.changements = const [],
    this.dividende,
    this.spark = const [],
  });

  @override
  List<Object?> get props => [symbol, nom, cours, variation, date, decision, score, changements, dividende, spark];
}
