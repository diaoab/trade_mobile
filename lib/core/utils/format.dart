import 'package:intl/intl.dart';

/// Formats français des chiffres et des dates (cours en FCFA, sans décimales).
class Format {
  Format._();

  static String nombre(num? valeur, {int decimales = 0}) {
    if (valeur == null) return '—';
    final f = NumberFormat.decimalPatternDigits(locale: 'fr_FR', decimalDigits: decimales);
    // Espace insécable fine du format français → espace insécable simple,
    // présente dans toutes les polices.
    return f.format(valeur).replaceAll(' ', ' ');
  }

  static String _signe(num valeur) => valeur > 0 ? '+' : (valeur < 0 ? '−' : '');

  static String pourcentage(num? valeur, {int decimales = 2}) {
    if (valeur == null) return '—';
    return '${_signe(valeur)}${nombre(valeur.abs(), decimales: decimales)} %';
  }

  static String signe(num? valeur) {
    if (valeur == null) return '—';
    return '${_signe(valeur)}${nombre(valeur.abs())}';
  }

  static DateTime? _date(String? valeur) =>
      valeur == null || valeur.length < 10 ? null : DateTime.tryParse(valeur.substring(0, 10));

  /// 12 mars 2026
  static String date(String? valeur) {
    final d = _date(valeur);
    return d == null ? '—' : DateFormat('d MMMM y', 'fr_FR').format(d);
  }

  /// 12 mars
  static String dateCourte(String? valeur) {
    final d = _date(valeur);
    return d == null ? '—' : DateFormat('d MMM', 'fr_FR').format(d);
  }

  /// Saisie souple des montants : virgule décimale et espaces acceptés.
  static double? lireNombre(String texte) =>
      double.tryParse(texte.replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.'));
}
