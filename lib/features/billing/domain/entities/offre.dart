import 'package:equatable/equatable.dart';

/// Offre Pro : prix d'une période et quota de l'assistant.
class Offre extends Equatable {
  final int prix;
  final String devise;
  final int jours;
  final int limiteAssistant;

  /// `false` tant que les clés PayDunya ne sont pas configurées côté API.
  final bool disponible;

  const Offre({required this.prix, required this.devise, required this.jours, required this.limiteAssistant, required this.disponible});

  @override
  List<Object?> get props => [prix, devise, jours, limiteAssistant, disponible];
}

/// Facture PayDunya ouverte : page de paiement et jeton de vérification.
class Facture extends Equatable {
  final String urlPaiement;
  final String jeton;

  const Facture({required this.urlPaiement, required this.jeton});

  @override
  List<Object?> get props => [urlPaiement, jeton];
}
