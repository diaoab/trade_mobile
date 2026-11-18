import '../../domain/entities/market_entry.dart';

abstract class MarketState {}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<MarketEntry> titres;

  /// Récupération des cours du jour en cours.
  final bool recuperation;

  /// Résultat de la dernière récupération (succès ou erreur), à afficher une fois.
  final String? message;

  MarketLoaded(this.titres, {this.recuperation = false, this.message});

  /// Dernière séance connue parmi les titres.
  String? get derniereSeance {
    final dates = titres.map((t) => t.date).whereType<String>().toList()..sort();
    return dates.isEmpty ? null : dates.last;
  }
}

class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}
