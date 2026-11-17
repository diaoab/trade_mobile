import '../../../market/data/models/market_entry_model.dart';
import '../../domain/entities/alerte.dart';

class AlertesModel extends Alertes {
  const AlertesModel({required super.liste, required super.nonLues});

  factory AlertesModel.fromJson(Map<String, dynamic> json) => AlertesModel(
        liste: [
          for (final a in (json['alerts'] as List).cast<Map<String, dynamic>>())
            Alerte(
              id: a['id'] as String,
              type: a['kind'] == 'dividend' ? TypeAlerte.dividende : TypeAlerte.signal,
              symbol: a['symbol'] as String,
              nom: a['name'] as String,
              date: a['date'] as String,
              detenu: a['held'] == true,
              nonLue: a['unread'] == true,
              avant: a['before'] as String?,
              apres: a['after'] as String?,
              montant: nombreOuNull(a['amount']),
              dateButoir: a['cutoff'] as String?,
              joursRestants: a['days_left'] as int?,
            ),
        ],
        nonLues: (json['unread'] as int?) ?? 0,
      );
}
