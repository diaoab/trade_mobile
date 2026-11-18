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

  /// Palette inspirée de Sika Finance : bleu nuit (#1A2634), orange
  /// (#F8B133) en accent, vert et rouge francs pour les variations.
  static const nuit = AppColor(
    fond: Color(0xFF0F1823),
    surface: Color(0xFF1A2634),
    champ: Color(0xFF233244),
    separateur: Color(0xFF2E4055),
    texte: Color(0xFFF5F7FA),
    texteMoyen: Color(0xFFA3B0C0),
    texteFaible: Color(0xFF6B7A8C),
    encre: Color(0xFFF8B133),
    surEncre: Color(0xFF231703),
    hausse: Color(0xFF2ECC55),
    baisse: Color(0xFFF2434E),
    prudence: Color(0xFFFFD45C),
    serie1: Color(0xFF5DA9F6),
    serie2: Color(0xFFF8B133),
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
