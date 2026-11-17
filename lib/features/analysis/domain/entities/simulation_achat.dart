import 'package:equatable/equatable.dart';

/// Ce que donnerait un achat de [budget] FCFA au cours [cours], frais
/// compris. Les frais d'un aller-retour sont partagés à moitié entre l'achat
/// et la vente.
class SimulationAchat extends Equatable {
  final double budget;
  final double cours;
  final double fraisAllerRetour;
  final double? dividendeParAction;

  const SimulationAchat({
    required this.budget,
    required this.cours,
    required this.fraisAllerRetour,
    this.dividendeParAction,
  });

  /// Frais d'un seul sens (achat ou vente), en fraction.
  double get _tauxSens => fraisAllerRetour / 2 / 100;

  /// Nombre d'actions entières que le budget permet d'acheter, frais d'achat
  /// compris.
  int get quantite => cours <= 0 ? 0 : (budget / (cours * (1 + _tauxSens))).floor();

  double get montantTitres => quantite * cours;
  double get fraisAchat => montantTitres * _tauxSens;
  double get totalDebourse => montantTitres + fraisAchat;
  double get reste => budget - totalDebourse;

  /// Dividende du prochain détachement pour la quantité achetée.
  double? get dividende => dividendeParAction == null ? null : quantite * dividendeParAction!;

  /// Cours de revente à partir duquel l'opération ne perd rien, frais
  /// d'achat et de vente compris (dividende non compté).
  double get coursEquilibre => _tauxSens >= 1 ? double.infinity : cours * (1 + _tauxSens) / (1 - _tauxSens);

  /// Hausse nécessaire pour atteindre [coursEquilibre], en %.
  double get hausseEquilibre => (coursEquilibre / cours - 1) * 100;

  /// Résultat net d'une revente après une variation du cours de
  /// [variationPct] %, frais d'achat et de vente déduits.
  double resultatSi(double variationPct) {
    final revente = montantTitres * (1 + variationPct / 100);
    return revente - revente * _tauxSens - totalDebourse;
  }

  @override
  List<Object?> get props => [budget, cours, fraisAllerRetour, dividendeParAction];
}
