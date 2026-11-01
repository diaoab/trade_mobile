import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_call.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String motDePasse);
  Future<AuthResponseModel> register(String email, String motDePasse);
  Future<void> logout(String refreshToken);
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login(String email, String motDePasse) async {
    final r = await dio.post(Env.login, data: {'email': email.trim(), 'password': motDePasse});
    return AuthResponseModel.fromJson(donnees(r));
  }

  @override
  Future<AuthResponseModel> register(String email, String motDePasse) async {
    final r = await dio.post(Env.register, data: {'email': email.trim(), 'password': motDePasse});
    return AuthResponseModel.fromJson(donnees(r));
  }

  @override
  Future<void> logout(String refreshToken) => dio.post(Env.authLogout, data: {'refresh_token': refreshToken});

  @override
  Future<UserModel> me() async => UserModel.fromJson(donnees(await dio.get(Env.accountMe)));
}
