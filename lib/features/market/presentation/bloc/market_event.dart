abstract class MarketEvent {}

class LoadMarket extends MarketEvent {}

/// Récupère les cours du jour puis recharge le Marché.
class RecupererCoursDuJour extends MarketEvent {}
