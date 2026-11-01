import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../market/domain/entities/market_entry.dart';

/// Sens d'un indicateur pour la décision.
enum Ton { positif, negatif, neutre }

/// Lecture d'un indicateur : nom, explication, sens, pris en compte ou non.
class DetailIndicateur extends Equatable {
  final String indicateur;
  final Ton ton;
  final bool compte;
  final String texte;

  const DetailIndicateur({required this.indicateur, required this.ton, required this.compte, required this.texte});

  @override
  List<Object?> get props => [indicateur, ton, compte, texte];
}

class ResultatDecision extends Equatable {
  final String decision;
  final double score;
  final double confiance;
  final double scoreTechnique;
  final double? scoreRisque;
  final int positifs;
  final int negatifs;
  final int neutres;
  final List<String> alertesLiquidite;
  final List<DetailIndicateur> details;

  const ResultatDecision({
    required this.decision,
    required this.score,
    required this.confiance,
    required this.scoreTechnique,
    this.scoreRisque,
    required this.positifs,
    required this.negatifs,
    required this.neutres,
    this.alertesLiquidite = const [],
    this.details = const [],
  });

  @override
  List<Object?> get props =>
      [decision, score, confiance, scoreTechnique, scoreRisque, positifs, negatifs, neutres, alertesLiquidite, details];
}

/// Modèle statistique : probabilité de surperformance à l'horizon donné.
class Prediction extends Equatable {
  final double? probabiliteHausse;

  /// `false` tant que le modèle ne bat pas la référence naïve : affiché à
  /// titre indicatif, hors du score.
  final bool compte;
  final int? horizonJours;

  const Prediction({this.probabiliteHausse, required this.compte, this.horizonJours});

  @override
  List<Object?> get props => [probabiliteHausse, compte, horizonJours];
}

/// Séries du graphique : dates et une série par clé (Close, MM20, MM50,
/// Bollinger_Upper, Bollinger_Lower).
class SeriesGraphique extends Equatable {
  final List<String> dates;
  final Map<String, List<double?>> series;

  const SeriesGraphique({required this.dates, required this.series});

  List<double?> operator [](String cle) => series[cle] ?? const [];

  @override
  List<Object?> get props => [dates, series];
}

class Analysis extends Equatable {
  final String symbol;
  final String nom;
  final double cours;
  final double? variation;
  final String? seance;
  final ResultatDecision resultat;
  final Prediction prediction;
  final Dividende? dividende;
  final SeriesGraphique graphique;

  const Analysis({
    required this.symbol,
    required this.nom,
    required this.cours,
    this.variation,
    this.seance,
    required this.resultat,
    required this.prediction,
    this.dividende,
    required this.graphique,
  });

  @override
  List<Object?> get props => [symbol, nom, cours, variation, seance, resultat, prediction, dividende, graphique];
}

/// Message de la conversation avec l'assistant.
class MessageAssistant extends Equatable {
  /// "user" ou "assistant".
  final String role;
  final String contenu;

  const MessageAssistant({required this.role, required this.contenu});

  bool get deLUtilisateur => role == 'user';

  Map<String, String> toJson() => {'role': role, 'content': contenu};

  @override
  List<Object?> get props => [role, contenu];
}

/// Réponse de l'assistant et quota restant pour la journée.
class ReponseAssistant extends Equatable {
  final String reponse;
  final Quota quota;

  const ReponseAssistant({required this.reponse, required this.quota});

  @override
  List<Object?> get props => [reponse, quota];
}
