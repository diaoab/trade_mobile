import 'package:equatable/equatable.dart';

/// Questions à l'assistant aujourd'hui, selon l'offre.
class Quota extends Equatable {
  final int utilisees;
  final int limite;

  const Quota({required this.utilisees, required this.limite});

  @override
  List<Object?> get props => [utilisees, limite];
}

class User extends Equatable {
  final int id;
  final String email;

  /// "free" ou "pro" (offre en vigueur).
  final String plan;
  final String? proJusquau;
  final Quota assistant;

  const User({required this.id, required this.email, required this.plan, this.proJusquau, required this.assistant});

  bool get estPro => plan == 'pro';

  @override
  List<Object?> get props => [id, email, plan, proJusquau, assistant];
}
