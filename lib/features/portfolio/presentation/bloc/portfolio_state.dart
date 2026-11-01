import '../../domain/entities/portfolio.dart';

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final Portfolio portfolio;

  /// Échec d'un ajout ou d'une suppression : le portefeuille reste affiché.
  final String? erreurAction;

  /// Incrémenté à chaque ajout réussi, pour fermer le formulaire.
  final int ajouts;

  PortfolioLoaded(this.portfolio, {this.erreurAction, this.ajouts = 0});
}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}
