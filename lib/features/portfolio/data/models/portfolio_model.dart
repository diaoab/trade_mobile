import 'package:intl/intl.dart';

import '../../../market/data/models/market_entry_model.dart';
import '../../domain/entities/portfolio.dart';

double _n(Object? v) => nombreOuNull(v) ?? 0;

class PortfolioModel extends Portfolio {
  const PortfolioModel({required super.positions, required super.totaux});

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final t = json['totals'] as Map<String, dynamic>;
    return PortfolioModel(
      positions: [
        for (final p in (json['positions'] as List).cast<Map<String, dynamic>>())
          Position(
            id: p['id'] as int,
            symbol: p['symbol'] as String,
            nom: p['name'] as String,
            quantite: _n(p['quantity']),
            prixAchat: _n(p['buy_price']),
            dateAchat: p['buy_date'] as String,
            dateCours: p['last_date'] as String?,
            enAttenteCours: p['awaiting_quote'] == true,
            valorisation: p['valuation'] is Map<String, dynamic> ? _valorisation(p['valuation'] as Map<String, dynamic>) : null,
          ),
      ],
      totaux: TotauxPortefeuille(
        cout: _n(t['cost']),
        valeur: _n(t['value']),
        dividendes: _n(t['dividends']),
        frais: _n(t['fees']),
        net: _n(t['net']),
        netPct: nombreOuNull(t['net_pct']),
        dateCours: t['as_of'] as String?,
        enAttenteCours: (t['awaiting_quote'] as int?) ?? 0,
      ),
    );
  }

  static Valorisation _valorisation(Map<String, dynamic> v) => Valorisation(
        cout: _n(v['cost']),
        valeur: _n(v['value']),
        dividendes: _n(v['dividends']),
        frais: _n(v['fees']),
        net: _n(v['net']),
        netPct: _n(v['net_pct']),
      );
}

extension NouvellePositionJson on NouvellePosition {
  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantite,
        'buy_price': prixAchat,
        'buy_date': DateFormat('yyyy-MM-dd').format(dateAchat),
      };
}
