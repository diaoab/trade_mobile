import 'package:equatable/equatable.dart';

/// Valorisation d'une position au dernier cours coté.
class Valorisation extends Equatable {
  final double cout;
  final double valeur;
  final double dividendes;
  final double frais;

  /// Plus-value latente + dividendes perçus − frais estimés d'un aller-retour.
  final double net;
  final double netPct;

  const Valorisation({
    required this.cout,
    required this.valeur,
    required this.dividendes,
    required this.frais,
    required this.net,
    required this.netPct,
  });

  @override
  List<Object?> get props => [cout, valeur, dividendes, frais, net, netPct];
}

class Position extends Equatable {
  final int id;
  final String symbol;
  final String nom;
  final double quantite;
  final double prixAchat;
  final String dateAchat;

  /// Séance du cours utilisé pour la valorisation (AAAA-MM-JJ).
  final String? dateCours;

  /// Achat postérieur au dernier cours connu : pas encore de valorisation.
  final bool enAttenteCours;
  final Valorisation? valorisation;

  const Position({
    required this.id,
    required this.symbol,
    required this.nom,
    required this.quantite,
    required this.prixAchat,
    required this.dateAchat,
    this.dateCours,
    this.enAttenteCours = false,
    this.valorisation,
  });

  @override
  List<Object?> get props => [id, symbol, nom, quantite, prixAchat, dateAchat, dateCours, enAttenteCours, valorisation];
}

class TotauxPortefeuille extends Equatable {
  final double cout;
  final double valeur;
  final double dividendes;
  final double frais;
  final double net;
  final double? netPct;

  /// Séance la plus ancienne parmi les cours utilisés : la valorisation
  /// n'est pas plus récente que celle-ci.
  final String? dateCours;

  /// Positions achetées après le dernier cours, exclues des totaux.
  final int enAttenteCours;

  const TotauxPortefeuille({
    required this.cout,
    required this.valeur,
    required this.dividendes,
    required this.frais,
    required this.net,
    this.netPct,
    this.dateCours,
    this.enAttenteCours = 0,
  });

  double get plusValueLatente => valeur - cout;

  @override
  List<Object?> get props => [cout, valeur, dividendes, frais, net, netPct, dateCours, enAttenteCours];
}

class Portfolio extends Equatable {
  final List<Position> positions;
  final TotauxPortefeuille totaux;

  const Portfolio({required this.positions, required this.totaux});

  @override
  List<Object?> get props => [positions, totaux];
}

/// Saisie d'une nouvelle position.
/// Achat à enregistrer : le titre et la quantité. Le serveur fixe le prix
/// (cours actuel) et la date (aujourd'hui).
class NouvellePosition extends Equatable {
  final String symbol;
  final double quantite;

  const NouvellePosition({required this.symbol, required this.quantite});

  @override
  List<Object?> get props => [symbol, quantite];
}
