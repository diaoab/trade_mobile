import 'package:flutter/material.dart';

/// app_color.dart — Jetons de couleur, nommés par rôle.
///
/// Style « fintech sombre » : fond bleu nuit, cartes plus claires pour la
/// profondeur, un accent turquoise pour l'action, et des couleurs vives
/// réservées à ce qui a un sens financier (hausse, baisse, prudence).
@immutable
class AppColor extends ThemeExtension<AppColor> {
  /// Fond de l'écran.
  final Color fond;

  /// Cartes, sections, pastilles.
  final Color surface;

  /// Fond des champs de saisie, posés sur une carte.
  final Color champ;
  final Color separateur;
  final Color texte;
  final Color texteMoyen;
  final Color texteFaible;

  /// Couleur d'action (boutons principaux, éléments actifs).
  final Color encre;

  /// Texte posé sur [encre].
  final Color surEncre;
  final Color hausse;
  final Color baisse;
  final Color prudence;
  final Color serie1;
  final Color serie2;
  final Color bande;

  const AppColor({
    required this.fond,
    required this.surface,
    required this.champ,
    required this.separateur,
    required this.texte,
    required this.texteMoyen,
    required this.texteFaible,
    required this.encre,
    required this.surEncre,
    required this.hausse,
    required this.baisse,
    required this.prudence,
    required this.serie1,
    required this.serie2,
    required this.bande,
  });

  static const nuit = AppColor(
    fond: Color(0xFF0A0F1C),
    surface: Color(0xFF121A2B),
    champ: Color(0xFF1A2438),
    separateur: Color(0xFF232F47),
    texte: Color(0xFFF1F5F9),
    texteMoyen: Color(0xFF94A3B8),
    texteFaible: Color(0xFF5E6B82),
    encre: Color(0xFF2DD4BF),
    surEncre: Color(0xFF04201C),
    hausse: Color(0xFF34D399),
    baisse: Color(0xFFFB7185),
    prudence: Color(0xFFFBBF24),
    serie1: Color(0xFF60A5FA),
    serie2: Color(0xFFF59E0B),
    bande: Color(0x14FFFFFF),
  );

  /// Couleur d'une variation : neutre à zéro, verte en hausse, rouge en baisse.
  Color variation(num? valeur) {
    if (valeur == null || valeur == 0) return texteMoyen;
    return valeur > 0 ? hausse : baisse;
  }

  @override
  AppColor copyWith() => this;

  @override
  AppColor lerp(ThemeExtension<AppColor>? other, double t) => t < 0.5 || other is! AppColor ? this : other;
}

extension CouleursContexte on BuildContext {
  AppColor get couleurs => Theme.of(this).extension<AppColor>()!;
}
