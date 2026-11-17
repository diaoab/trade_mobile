import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/reset_password.dart';

/// Étapes de l'écran « mot de passe oublié ».
enum EtapeReinitialisation { email, code, nouveau, termine }

abstract class ResetPasswordEvent {}

class CodeDemande extends ResetPasswordEvent {
  final String email;
  CodeDemande(this.email);
}

/// Nouveau code pour la même adresse.
class CodeRedemande extends ResetPasswordEvent {}

class CodeSaisi extends ResetPasswordEvent {
  final String code;
  CodeSaisi(this.code);
}

class NouveauMotDePasseSaisi extends ResetPasswordEvent {
  final String motDePasse;
  NouveauMotDePasseSaisi(this.motDePasse);
}

/// Retour à la saisie de l'adresse.
class EmailAChanger extends ResetPasswordEvent {}

class ResetPasswordState {
  final EtapeReinitialisation etape;
  final String email;
  final String code;
  final bool enCours;
  final String? erreur;

  /// Incrémenté à chaque code envoyé (« code renvoyé »).
  final int codesEnvoyes;

  const ResetPasswordState({
    this.etape = EtapeReinitialisation.email,
    this.email = '',
    this.code = '',
    this.enCours = false,
    this.erreur,
    this.codesEnvoyes = 0,
  });

  ResetPasswordState copyWith({
    EtapeReinitialisation? etape,
    String? email,
    String? code,
    bool? enCours,
    String? erreur,
    int? codesEnvoyes,
  }) => ResetPasswordState(
    etape: etape ?? this.etape,
    email: email ?? this.email,
    code: code ?? this.code,
    enCours: enCours ?? this.enCours,
    erreur: erreur,
    codesEnvoyes: codesEnvoyes ?? this.codesEnvoyes,
  );
}

/// Mot de passe oublié : e-mail → code reçu → nouveau mot de passe.
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPassword resetPassword;

  /// Règle de l'API pour un compte de l'app.
  static const longueurMin = 8;

  ResetPasswordBloc({required this.resetPassword}) : super(const ResetPasswordState()) {
    on<CodeDemande>((event, emit) => _envoyerCode(event.email.trim(), emit));
    on<CodeRedemande>((_, emit) => _envoyerCode(state.email, emit));
    on<CodeSaisi>(_onCode);
    on<NouveauMotDePasseSaisi>(_onNouveau);
    on<EmailAChanger>((_, emit) => emit(state.copyWith(etape: EtapeReinitialisation.email, code: '')));
  }

  // L'API répond de la même façon que le compte existe ou non : on passe
  // toujours à l'étape du code.
  Future<void> _envoyerCode(String email, Emitter<ResetPasswordState> emit) async {
    if (email.isEmpty || state.enCours) return;
    emit(state.copyWith(email: email, enCours: true));
    final result = await resetPassword.demanderCode(email);
    result.fold(
      (f) => emit(state.copyWith(enCours: false, erreur: f.errorMessage)),
      (_) =>
          emit(state.copyWith(etape: EtapeReinitialisation.code, enCours: false, codesEnvoyes: state.codesEnvoyes + 1)),
    );
  }

  Future<void> _onCode(CodeSaisi event, Emitter<ResetPasswordState> emit) async {
    final code = event.code.trim();
    if (code.length != 6 || state.enCours) return;
    emit(state.copyWith(enCours: true));
    final result = await resetPassword.verifierCode(state.email, code);
    result.fold(
      (f) => emit(state.copyWith(enCours: false, erreur: f.errorMessage)),
      (_) => emit(state.copyWith(etape: EtapeReinitialisation.nouveau, code: code, enCours: false)),
    );
  }

  Future<void> _onNouveau(NouveauMotDePasseSaisi event, Emitter<ResetPasswordState> emit) async {
    if (state.enCours) return;
    if (event.motDePasse.length < longueurMin) {
      return emit(state.copyWith(erreur: 'Le mot de passe doit faire au moins $longueurMin caractères.'));
    }
    emit(state.copyWith(enCours: true));
    final result = await resetPassword.reinitialiser(state.email, state.code, event.motDePasse);
    result.fold(
      (f) => emit(state.copyWith(enCours: false, erreur: f.errorMessage)),
      (_) => emit(state.copyWith(etape: EtapeReinitialisation.termine, enCours: false)),
    );
  }
}
