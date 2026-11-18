import 'package:equatable/equatable.dart';

/// Questions à l'assistant aujourd'hui, selon l'offre.
class Quota extends Equatable {
  final int utilisees;
  final int limite;

  const Quota({required this.utilisees, required this.limite});

  @override
  List<Object?> get props => [utilisees, limite];
}

/// Limites de l'offre (null : sans limite).
class Limites extends Equatable {
  final int? positions;
  final int? favoris;

  const Limites({this.positions, this.favoris});

  @override
  List<Object?> get props => [positions, favoris];
}

class User extends Equatable {
  final int id;
  final String email;
  final String? prenom;
  final String? nom;
  final String? telephone;

  /// "free" ou "pro" (offre en vigueur).
  final String plan;
  final String? proJusquau;
  final Quota assistant;

  /// Mot de passe provisoire (compte créé par l'administration) : à changer
  /// avant d'utiliser l'app.
  final bool doitChangerMotDePasse;
  final Limites limites;

  const User({
    required this.id,
    required this.email,
    this.prenom,
    this.nom,
    this.telephone,
    required this.plan,
    this.proJusquau,
    required this.assistant,
    this.doitChangerMotDePasse = false,
    this.limites = const Limites(),
  });

  bool get estPro => plan == 'pro';

  /// Prénom et nom, sinon l'e-mail.
  String get nomAffiche {
    final complet = [prenom, nom].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    return complet.isEmpty ? email : complet;
  }

  @override
  List<Object?> get props =>
      [id, email, prenom, nom, telephone, plan, proJusquau, assistant, doitChangerMotDePasse, limites];
}
