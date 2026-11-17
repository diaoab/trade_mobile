import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/preferences.dart';
import '../models/preferences_model.dart';

abstract class AccountRemoteDataSource {
  /// `null` efface le champ. Renvoie le compte à jour.
  Future<UserModel> modifierProfil({required String? prenom, required String? nom, required String? telephone});

  Future<PreferencesModel> getPreferences();
  Future<PreferencesModel> modifierPreferences(ModificationPreferences modification);

  /// Renvoie la nouvelle session de cet appareil (les autres sont fermées).
  Future<({String token, String refreshToken})> changerMotDePasse(String actuel, String nouveau);
  Future<void> supprimerCompte();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;
  AccountRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> modifierProfil({required String? prenom, required String? nom, required String? telephone}) async =>
      UserModel.fromJson(donnees(await dio.patch(Env.accountMe, data: {
        'first_name': prenom,
        'last_name': nom,
        'phone': telephone,
      })));

  @override
  Future<PreferencesModel> getPreferences() async =>
      PreferencesModel.fromJson(donnees(await dio.get(Env.accountPreferences)));

  @override
  Future<PreferencesModel> modifierPreferences(ModificationPreferences modification) async =>
      PreferencesModel.fromJson(donnees(await dio.put(Env.accountPreferences, data: modification.toJson())));

  @override
  Future<({String token, String refreshToken})> changerMotDePasse(String actuel, String nouveau) async {
    final r = await dio.put(Env.authPassword, data: {'current_password': actuel, 'new_password': nouveau});
    final session = donnees<Map<String, dynamic>>(r);
    return (token: session['token'] as String, refreshToken: session['refresh_token'] as String);
  }

  @override
  Future<void> supprimerCompte() => dio.delete(Env.accountMe);
}
