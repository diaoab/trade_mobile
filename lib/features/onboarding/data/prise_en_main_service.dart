import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Retient sur l'appareil que la prise en main a été vue.
class PriseEnMainService {
  final FlutterSecureStorage secureStorage;
  PriseEnMainService({required this.secureStorage});

  static const _cle = 'prise_en_main_vue';

  Future<bool> dejaVue() async {
    try {
      return await secureStorage.read(key: _cle) == '1';
    } catch (_) {
      // Trousseau illisible : mieux vaut ne pas la remontrer à chaque fois.
      return true;
    }
  }

  Future<void> marquerVue() async {
    try {
      await secureStorage.write(key: _cle, value: '1');
    } catch (_) {}
  }
}
