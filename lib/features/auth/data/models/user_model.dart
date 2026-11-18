import '../../domain/entities/user.dart';

class QuotaModel extends Quota {
  const QuotaModel({required super.utilisees, required super.limite});

  factory QuotaModel.fromJson(Map<String, dynamic> json) =>
      QuotaModel(utilisees: json['used'] as int, limite: json['limit'] as int);
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.prenom,
    super.nom,
    super.telephone,
    required super.plan,
    super.proJusquau,
    required super.assistant,
    super.doitChangerMotDePasse,
    super.limites,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        prenom: json['first_name'] as String?,
        nom: json['last_name'] as String?,
        telephone: json['phone'] as String?,
        plan: json['plan'] as String,
        proJusquau: json['pro_until'] as String?,
        assistant: QuotaModel.fromJson(json['assistant'] as Map<String, dynamic>),
        doitChangerMotDePasse: json['must_change_password'] == true,
        limites: json['limits'] is Map
            ? Limites(positions: json['limits']['positions'] as int?, favoris: json['limits']['favorites'] as int?)
            : const Limites(),
      );
}

/// Réponse de /auth/login et /auth/register : jetons + compte.
class AuthResponseModel {
  final String token;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({required this.token, required this.refreshToken, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
        token: json['token'] as String,
        refreshToken: json['refresh_token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
