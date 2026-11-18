import 'package:equatable/equatable.dart';

/// Notifications : interrupteur général et types d'alerte.
class ReglagesNotifications extends Equatable {
  final bool actives;
  final bool achat;
  final bool vente;
  final bool dividende;

  const ReglagesNotifications({this.actives = true, this.achat = true, this.vente = true, this.dividende = true});

  @override
  List<Object?> get props => [actives, achat, vente, dividende];
}

/// Réglages d'analyse du compte.
class Preferences extends Equatable {
  /// Indicateurs pris en compte dans le signal.
  final List<String> indicateurs;
  final bool ajusterDividendes;

  /// Frais d'un aller-retour, en % du montant.
  final double fraisAllerRetour;

  /// Indicateurs proposés par l'API.
  final List<String> options;

  final ReglagesNotifications notifications;

  const Preferences({
    required this.indicateurs,
    required this.ajusterDividendes,
    required this.fraisAllerRetour,
    required this.options,
    this.notifications = const ReglagesNotifications(),
  });

  @override
  List<Object?> get props => [indicateurs, ajusterDividendes, fraisAllerRetour, options, notifications];
}

/// Modification partielle des réglages : seuls les champs fournis changent.
class ModificationPreferences {
  final List<String>? indicateurs;
  final bool? ajusterDividendes;
  final double? fraisAllerRetour;

  /// Notifications : {enabled|buy|sell|dividend: bool}, champs fournis seulement.
  final Map<String, bool>? notifications;

  const ModificationPreferences({this.indicateurs, this.ajusterDividendes, this.fraisAllerRetour, this.notifications});

  Map<String, dynamic> toJson() => {
        'selected_parameters': ?indicateurs,
        'adjust_dividends': ?ajusterDividendes,
        'round_trip_fee': ?fraisAllerRetour,
        'notifications': ?notifications,
      };
}
