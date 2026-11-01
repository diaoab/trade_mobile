import '../../../market/data/models/market_entry_model.dart';
import '../../domain/entities/preferences.dart';

class PreferencesModel extends Preferences {
  const PreferencesModel({
    required super.indicateurs,
    required super.ajusterDividendes,
    required super.fraisAllerRetour,
    required super.options,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) => PreferencesModel(
        indicateurs: (json['selected_parameters'] as List).cast<String>(),
        ajusterDividendes: json['adjust_dividends'] as bool,
        fraisAllerRetour: nombreOuNull(json['round_trip_fee']) ?? 0,
        options: (json['indicator_options'] as List).cast<String>(),
      );
}
