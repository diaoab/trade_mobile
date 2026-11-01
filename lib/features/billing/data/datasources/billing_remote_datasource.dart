import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../../domain/entities/offre.dart';

abstract class BillingRemoteDataSource {
  Future<Offre> getOffre();
  Future<Facture> ouvrirFacture(String urlRetour);

  /// Statut de la facture vérifié auprès de PayDunya : completed, pending…
  Future<String> confirmer(String jeton);
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final Dio dio;
  BillingRemoteDataSourceImpl({required this.dio});

  @override
  Future<Offre> getOffre() async {
    final o = donnees<Map<String, dynamic>>(await dio.get(Env.billingOffer));
    return Offre(
      prix: o['price'] as int,
      devise: o['currency'] as String,
      jours: o['days'] as int,
      limiteAssistant: o['assistant_limit'] as int,
      disponible: o['available'] as bool,
    );
  }

  @override
  Future<Facture> ouvrirFacture(String urlRetour) async {
    final f = donnees<Map<String, dynamic>>(await dio.post(Env.billingCheckout, data: {'redirect_url': urlRetour}));
    return Facture(urlPaiement: f['checkout_url'] as String, jeton: f['token'] as String);
  }

  @override
  Future<String> confirmer(String jeton) async =>
      donnees<Map<String, dynamic>>(await dio.post(Env.billingConfirm, data: {'token': jeton}))['status'] as String;
}
