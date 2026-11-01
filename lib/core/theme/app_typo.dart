import 'package:flutter/material.dart';

/// app_typo.dart — Styles de texte de l'application (police système :
/// San Francisco sur iOS, Roboto sur Android).
class AppTypo {
  AppTypo._();

  /// Chiffres à chasse fixe : les colonnes de cours restent alignées.
  static const List<FontFeature> chiffres = [FontFeature.tabularFigures()];

  static TextStyle style({
    double taille = 16,
    FontWeight graisse = FontWeight.w400,
    Color? couleur,
    double? interlettre,
    double? hauteur,
    bool tabulaire = false,
  }) =>
      TextStyle(
        fontSize: taille,
        fontWeight: graisse,
        color: couleur,
        letterSpacing: interlettre,
        height: hauteur,
        fontFeatures: tabulaire ? chiffres : null,
      );
}
