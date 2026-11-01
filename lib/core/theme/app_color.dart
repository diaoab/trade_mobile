import 'package:flutter/material.dart';

/// app_color.dart — Jetons de couleur, nommés par rôle.
///
/// Palette neutre : l'encre et le papier portent l'interface, la couleur est
/// réservée à ce qui a un sens financier (hausse, baisse, signal).
@immutable
class AppColor extends ThemeExtension<AppColor> {
  final Color fond;
  final Color surface;
  final Color separateur;
  final Color texte;
  final Color texteMoyen;
  final Color texteFaible;
  final Color encre;
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

  /// Ivoire : papier chaud façon presse financière plutôt que blanc pur.
  static const clair = AppColor(
    fond: Color(0xFFF4EFE4),
    surface: Color(0xFFEAE4D6),
    separateur: Color(0xFFDDD5C3),
    texte: Color(0xFF1C1B17),
    texteMoyen: Color(0xFF6F6A5D),
    texteFaible: Color(0xFFA39E8F),
    encre: Color(0xFF1C1B17),
    surEncre: Color(0xFFF4EFE4),
    hausse: Color(0xFF0A7F50),
    baisse: Color(0xFFC42B36),
    prudence: Color(0xFF9A5D0A),
    serie1: Color(0xFF2F5FB3),
    serie2: Color(0xFFB06D0E),
    bande: Color(0x0F1C1B17),
  );

  static const sombre = AppColor(
    fond: Color(0xFF000000),
    surface: Color(0xFF151516),
    separateur: Color(0xFF262628),
    texte: Color(0xFFF5F5F4),
    texteMoyen: Color(0xFF9C9B97),
    texteFaible: Color(0xFF646360),
    encre: Color(0xFFF5F5F4),
    surEncre: Color(0xFF000000),
    hausse: Color(0xFF2DBE7E),
    baisse: Color(0xFFF2545F),
    prudence: Color(0xFFE2A23B),
    serie1: Color(0xFF5B8DEF),
    serie2: Color(0xFFE09A3A),
    bande: Color(0x0FF5F5F4),
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
