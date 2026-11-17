import 'package:equatable/equatable.dart';

enum TypeAlerte { signal, dividende }

/// Événement signalé à l'utilisateur : un signal qui bascule, ou la date
/// butoir d'un dividende qui approche sur un titre détenu.
class Alerte extends Equatable {
  final String id;
  final TypeAlerte type;
  final String symbol;
  final String nom;

  /// Séance de l'événement (AAAA-MM-JJ).
  final String date;

  /// Titre détenu dans le portefeuille.
  final bool detenu;
  final bool nonLue;

  // Signal
  final String? avant;
  final String? apres;

  // Dividende
  final double? montant;
  final String? dateButoir;
  final int? joursRestants;

  const Alerte({
    required this.id,
    required this.type,
    required this.symbol,
    required this.nom,
    required this.date,
    this.detenu = false,
    this.nonLue = false,
    this.avant,
    this.apres,
    this.montant,
    this.dateButoir,
    this.joursRestants,
  });

  @override
  List<Object?> get props => [id, type, symbol, nom, date, detenu, nonLue, avant, apres, montant, dateButoir, joursRestants];
}

class Alertes extends Equatable {
  final List<Alerte> liste;
  final int nonLues;

  const Alertes({required this.liste, required this.nonLues});

  @override
  List<Object?> get props => [liste, nonLues];
}
