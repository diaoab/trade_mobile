import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/update_preferences.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetPreferences getPreferences;
  final UpdatePreferences updatePreferences;
  final ChangePassword changePassword;
  final DeleteAccount deleteAccount;

  AccountBloc({
    required this.getPreferences,
    required this.updatePreferences,
    required this.changePassword,
    required this.deleteAccount,
  }) : super(const AccountState()) {
    on<LoadPreferences>(_onLoad);
    on<PreferencesChanged>(_onChanged);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteAccountEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadPreferences event, Emitter<AccountState> emit) async {
    emit(state.copyWith(chargement: state.preferences == null));
    final result = await getPreferences();
    result.fold(
      (f) => emit(state.copyWith(chargement: false, erreur: f.errorMessage)),
      (p) => emit(state.copyWith(chargement: false, preferences: p)),
    );
  }

  Future<void> _onChanged(PreferencesChanged event, Emitter<AccountState> emit) async {
    final result = await updatePreferences(event.modification);
    result.fold(
      (f) => emit(state.copyWith(erreur: f.errorMessage)),
      (p) => emit(state.copyWith(preferences: p)),
    );
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<AccountState> emit) async {
    emit(state.copyWith(motDePasseEnCours: true));
    final result = await changePassword(event.actuel, event.nouveau);
    result.fold(
      (f) => emit(state.copyWith(motDePasseEnCours: false, erreurMotDePasse: f.errorMessage)),
      (_) => emit(state.copyWith(motDePasseEnCours: false, motsDePasseChanges: state.motsDePasseChanges + 1)),
    );
  }

  Future<void> _onDelete(DeleteAccountEvent event, Emitter<AccountState> emit) async {
    final result = await deleteAccount();
    result.fold(
      (f) => emit(state.copyWith(erreur: f.errorMessage)),
      (_) => emit(state.copyWith(compteSupprime: true)),
    );
  }
}
