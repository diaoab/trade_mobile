/// app_dimensions.dart — Échelles d'espacement et de rayon.
library;

/// Espacements — multiples de 4.
class AppEspace {
  AppEspace._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;

  /// 20 — marge latérale d'un écran.
  static const double gouttiere = 20;
  static const double xl = 24;
  static const double xxl = 28;
}

class AppRayon {
  AppRayon._();

  static const double s = 8;
  static const double m = 10;
  static const double l = 14;
  static const double xl = 16;
}

/// Largeur maximale du contenu : sur tablette, une colonne lisible plutôt
/// qu'un écran étiré.
const double kLargeurMax = 680;
