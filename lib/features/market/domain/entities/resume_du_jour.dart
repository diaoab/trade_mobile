import 'package:equatable/equatable.dart';

import '../../../portfolio/domain/entities/portfolio.dart';
import 'market_entry.dart';

/// Bascule d'un signal entre la séance précédente et la dernière.
class BasculeSignal extends Equatable {
  final String symbol;
  final String nom;
  final String avant;
  final String apres;

  const BasculeSignal({required this.symbol, required this.nom, required this.avant, required this.apres});

  @override
  List<Object?> get props => [symbol, nom, avant, apres];
}

/// Dividende à venir dont la date butoir d'achat approche.
class DividendeProche extends Equatable {
  final String symbol;
  final String nom;
  final double montant;
  final String dateButoir;
  final int joursRestants;

  const DividendeProche({
    required this.symbol,
    required this.nom,
    required this.montant,
    required this.dateButoir,
    required this.joursRestants,
  });

  @override
  List<Object?> get props => [symbol, nom, montant, dateButoir, joursRestants];
}

/// Variation du portefeuille sur la dernière séance.
class SeancePortefeuille extends Equatable {
  final double montant;
  final double pourcentage;

  const SeancePortefeuille({required this.montant, required this.pourcentage});

  @override
  List<Object?> get props => [montant, pourcentage];
}

/// Ce qui a changé à la dernière séance, en tête de l'écran Marché : ce que
/// l'utilisateur doit savoir sans parcourir chaque titre.
class ResumeDuJour extends Equatable {
  final List<BasculeSignal> bascules;
  final List<DividendeProche> dividendes;

  /// Null sans portefeuille valorisé.
  final SeancePortefeuille? portefeuille;

  const ResumeDuJour({this.bascules = const [], this.dividendes = const [], this.portefeuille});

  /// Horizon des dividendes signalés, en jours.
  static const int horizonDividendes = 30;

  bool get estVide => bascules.isEmpty && dividendes.isEmpty && portefeuille == null;

  factory ResumeDuJour.calculer(List<MarketEntry> titres, {Portfolio? portfolio}) {
    final bascules = [
      for (final t in titres)
        if (t.decision != null && t.decisionPrecedente != null && t.decision != t.decisionPrecedente)
          BasculeSignal(symbol: t.symbol, nom: t.nom, avant: t.decisionPrecedente!, apres: t.decision!),
    ];

    final dividendes = [
      for (final t in titres)
        if (t.dividende != null && t.dividende!.joursRestants >= 0 && t.dividende!.joursRestants <= horizonDividendes)
          DividendeProche(
            symbol: t.symbol,
            nom: t.nom,
            montant: t.dividende!.montant,
            dateButoir: t.dividende!.dateButoir,
            joursRestants: t.dividende!.joursRestants,
          ),
    ]..sort((a, b) => a.joursRestants.compareTo(b.joursRestants));

    return ResumeDuJour(
      bascules: bascules,
      dividendes: dividendes,
      portefeuille: portfolio == null ? null : _seance(titres, portfolio),
    );
  }

  /// Variation de la valeur des positions sur la dernière séance : chaque
  /// position valorisée au cours du jour, comparée au cours de la veille
  /// déduit de la variation du titre.
  static SeancePortefeuille? _seance(List<MarketEntry> titres, Portfolio portfolio) {
    final parSymbole = {for (final t in titres) t.symbol: t};
    var valeur = 0.0;
    var veille = 0.0;
    for (final p in portfolio.positions) {
      final v = p.valorisation;
      final titre = parSymbole[p.symbol];
      final variation = titre?.variation;
      // Seulement si la position est valorisée à la même séance que le titre.
      if (v == null || titre == null || variation == null || p.dateCours != titre.date) continue;
      valeur += v.valeur;
      veille += v.valeur / (1 + variation / 100);
    }
    if (veille <= 0) return null;
    return SeancePortefeuille(montant: valeur - veille, pourcentage: (valeur / veille - 1) * 100);
  }

  @override
  List<Object?> get props => [bascules, dividendes, portefeuille];
}
