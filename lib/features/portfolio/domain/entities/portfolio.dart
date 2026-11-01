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
  final Valorisation? valorisation;

  const Position({
    required this.id,
    required this.symbol,
    required this.nom,
    required this.quantite,
    required this.prixAchat,
    required this.dateAchat,
    this.valorisation,
  });

  @override
  List<Object?> get props => [id, symbol, nom, quantite, prixAchat, dateAchat, valorisation];
}

class TotauxPortefeuille extends Equatable {
  final double cout;
  final double valeur;
  final double dividendes;
  final double frais;
  final double net;
  final double? netPct;

  const TotauxPortefeuille({
    required this.cout,
    required this.valeur,
    required this.dividendes,
    required this.frais,
    required this.net,
    this.netPct,
  });

  double get plusValueLatente => valeur - cout;

  @override
  List<Object?> get props => [cout, valeur, dividendes, frais, net, netPct];
}

class Portfolio extends Equatable {
  final List<Position> positions;
  final TotauxPortefeuille totaux;

  const Portfolio({required this.positions, required this.totaux});

  @override
  List<Object?> get props => [positions, totaux];
}

/// Saisie d'une nouvelle position.
class NouvellePosition extends Equatable {
  final String symbol;
  final double quantite;
  final double prixAchat;
  final DateTime dateAchat;

  const NouvellePosition({required this.symbol, required this.quantite, required this.prixAchat, required this.dateAchat});

  @override
  List<Object?> get props => [symbol, quantite, prixAchat, dateAchat];
}
