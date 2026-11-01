import 'package:equatable/equatable.dart';

/// Réglages d'analyse du compte.
class Preferences extends Equatable {
  /// Indicateurs pris en compte dans le signal.
  final List<String> indicateurs;
  final bool ajusterDividendes;

  /// Frais d'un aller-retour, en % du montant.
  final double fraisAllerRetour;

  /// Indicateurs proposés par l'API.
  final List<String> options;

  const Preferences({
    required this.indicateurs,
    required this.ajusterDividendes,
    required this.fraisAllerRetour,
    required this.options,
  });

  @override
  List<Object?> get props => [indicateurs, ajusterDividendes, fraisAllerRetour, options];
}

/// Modification partielle des réglages : seuls les champs fournis changent.
class ModificationPreferences {
  final List<String>? indicateurs;
  final bool? ajusterDividendes;
  final double? fraisAllerRetour;

  const ModificationPreferences({this.indicateurs, this.ajusterDividendes, this.fraisAllerRetour});

  Map<String, dynamic> toJson() => {
        'selected_parameters': ?indicateurs,
        'adjust_dividends': ?ajusterDividendes,
        'round_trip_fee': ?fraisAllerRetour,
      };
}
