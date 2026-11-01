import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
    required this.logoutUser,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
    on<SessionExpired>((_, emit) => emit(Unauthenticated(erreur: const SessionFailure().errorMessage)));
    on<UserRefreshRequested>(_onRefresh);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final result = await getCurrentUser();
    await result.fold(
      (failure) async {
        // Session refusée : on efface les jetons. Sans réseau, l'écran de
        // connexion s'affiche aussi, avec le message.
        if (failure is SessionFailure) await logoutUser();
        emit(Unauthenticated(erreur: failure is SessionFailure ? null : failure.errorMessage));
      },
      (user) async => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = event.creation
        ? await registerUser(event.email, event.motDePasse)
        : await loginUser(event.email, event.motDePasse);
    result.fold(
      (failure) => emit(Unauthenticated(erreur: failure.errorMessage)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await logoutUser();
    emit(Unauthenticated());
  }

  Future<void> _onRefresh(UserRefreshRequested event, Emitter<AuthState> emit) async {
    final result = await getCurrentUser();
    // Un échec réseau garde le compte affiché ; seule une session refusée déconnecte.
    result.fold(
      (failure) {
        if (failure is SessionFailure) emit(Unauthenticated(erreur: failure.errorMessage));
      },
      (user) => emit(Authenticated(user)),
    );
  }
}
