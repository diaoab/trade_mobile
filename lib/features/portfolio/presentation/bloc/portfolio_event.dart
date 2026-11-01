import '../../domain/entities/portfolio.dart';

abstract class PortfolioEvent {}

class LoadPortfolio extends PortfolioEvent {}

class PositionAdded extends PortfolioEvent {
  final NouvellePosition position;
  PositionAdded(this.position);
}

class PositionDeleted extends PortfolioEvent {
  final int id;
  PositionDeleted(this.id);
}
