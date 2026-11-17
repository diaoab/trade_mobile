import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/auth/domain/entities/user.dart';
import 'package:financial_ai_advisor/features/auth/domain/repositories/auth_repository.dart';
import 'package:financial_ai_advisor/features/auth/domain/usecases/get_current_user.dart';
import 'package:financial_ai_advisor/features/auth/domain/usecases/login_user.dart';
import 'package:financial_ai_advisor/features/auth/domain/usecases/logout_user.dart';
import 'package:financial_ai_advisor/features/auth/domain/usecases/register_user.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_event.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AuthRepository {}

const _user = User(id: 1, email: 'a@example.com', plan: 'free', assistant: Quota(utilisees: 0, limite: 3));

void main() {
  late _Repo repo;

  AuthBloc bloc() => AuthBloc(
        loginUser: LoginUser(repo),
        registerUser: RegisterUser(repo),
        getCurrentUser: GetCurrentUser(repo),
        logoutUser: LogoutUser(repo),
      );

  setUp(() {
    repo = _Repo();
    when(() => repo.logout()).thenAnswer((_) async {});
  });

  blocTest<AuthBloc, AuthState>(
    'reprend la session enregistrée au démarrage',
    setUp: () => when(() => repo.utilisateurCourant()).thenAnswer((_) async => const Right(_user)),
    build: bloc,
    act: (b) => b.add(AppStarted()),
    expect: () => [isA<Authenticated>().having((s) => s.user.email, 'email', 'a@example.com')],
  );

  blocTest<AuthBloc, AuthState>(
    'sans session, affiche la connexion sans message et efface les jetons',
    setUp: () => when(() => repo.utilisateurCourant()).thenAnswer((_) async => const Left(SessionFailure())),
    build: bloc,
    act: (b) => b.add(AppStarted()),
    expect: () => [isA<Unauthenticated>().having((s) => s.erreur, 'erreur', isNull)],
    verify: (_) => verify(() => repo.logout()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'un mauvais mot de passe affiche le message de l’API',
    setUp: () => when(() => repo.login(any(), any()))
        .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'E-mail ou mot de passe incorrect.'))),
    build: bloc,
    act: (b) => b.add(LoginRequested(email: 'a@example.com', motDePasse: 'x')),
    expect: () => [
      isA<AuthLoading>(),
      isA<Unauthenticated>().having((s) => s.erreur, 'erreur', 'E-mail ou mot de passe incorrect.'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'un compte désactivé revient à la connexion avec le message de l’API',
    build: bloc,
    seed: () => Authenticated(_user),
    act: (b) => b.add(SessionExpired(message: 'Ton compte a été désactivé. Contacte le support.')),
    expect: () => [
      isA<Unauthenticated>().having((s) => s.erreur, 'erreur', 'Ton compte a été désactivé. Contacte le support.'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'le compte modifié (profil) remplace le compte affiché',
    build: bloc,
    seed: () => Authenticated(_user),
    act: (b) => b.add(UserUpdated(const User(id: 1, email: 'a@example.com', prenom: 'Awa', plan: 'free', assistant: Quota(utilisees: 0, limite: 3)))),
    expect: () => [isA<Authenticated>().having((s) => s.user.nomAffiche, 'nom', 'Awa')],
  );

  blocTest<AuthBloc, AuthState>(
    'une erreur réseau à l’actualisation du compte ne déconnecte pas',
    setUp: () => when(() => repo.utilisateurCourant())
        .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Serveur injoignable'))),
    build: bloc,
    seed: () => Authenticated(_user),
    act: (b) => b.add(UserRefreshRequested()),
    expect: () => <AuthState>[],
  );
}
