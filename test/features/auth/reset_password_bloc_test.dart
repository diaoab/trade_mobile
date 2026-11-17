import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/auth/data/models/user_model.dart';
import 'package:financial_ai_advisor/features/auth/domain/repositories/auth_repository.dart';
import 'package:financial_ai_advisor/features/auth/domain/usecases/reset_password.dart';
import 'package:financial_ai_advisor/features/auth/presentation/bloc/reset_password_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AuthRepository {}

void main() {
  late _Repo repo;

  setUp(() {
    repo = _Repo();
    when(() => repo.demanderCode(any())).thenAnswer((_) async => const Right(null));
    when(() => repo.verifierCode(any(), any())).thenAnswer((_) async => const Right(null));
    when(() => repo.reinitialiser(any(), any(), any())).thenAnswer((_) async => const Right(null));
  });

  ResetPasswordBloc bloc() => ResetPasswordBloc(resetPassword: ResetPassword(repo));

  blocTest<ResetPasswordBloc, ResetPasswordState>(
    'enchaîne e-mail, code et nouveau mot de passe',
    build: bloc,
    act: (b) async {
      b.add(CodeDemande(' awa@example.com '));
      await Future<void>.delayed(Duration.zero);
      b.add(CodeSaisi('123456'));
      await Future<void>.delayed(Duration.zero);
      b.add(NouveauMotDePasseSaisi('Nouveau2026'));
    },
    skip: 5,
    expect: () => [isA<ResetPasswordState>().having((s) => s.etape, 'etape', EtapeReinitialisation.termine)],
    verify: (_) {
      verify(() => repo.demanderCode('awa@example.com')).called(1);
      verify(() => repo.verifierCode('awa@example.com', '123456')).called(1);
      verify(() => repo.reinitialiser('awa@example.com', '123456', 'Nouveau2026')).called(1);
    },
  );

  blocTest<ResetPasswordBloc, ResetPasswordState>(
    'un code refusé reste à l’étape du code avec le message de l’API',
    setUp: () =>
        when(() => repo.verifierCode(any(), any()))
            .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Code invalide ou expiré.'))),
    build: bloc,
    seed: () => const ResetPasswordState(etape: EtapeReinitialisation.code, email: 'awa@example.com'),
    act: (b) => b.add(CodeSaisi('000000')),
    expect: () => [
      isA<ResetPasswordState>().having((s) => s.enCours, 'enCours', true),
      isA<ResetPasswordState>()
          .having((s) => s.etape, 'etape', EtapeReinitialisation.code)
          .having((s) => s.erreur, 'erreur', 'Code invalide ou expiré.'),
    ],
  );

  blocTest<ResetPasswordBloc, ResetPasswordState>(
    'un mot de passe trop court n’est pas envoyé',
    build: bloc,
    seed: () =>
        const ResetPasswordState(etape: EtapeReinitialisation.nouveau, email: 'awa@example.com', code: '123456'),
    act: (b) => b.add(NouveauMotDePasseSaisi('court')),
    expect: () => [isA<ResetPasswordState>().having((s) => s.erreur, 'erreur', contains('8 caractères'))],
    verify: (_) => verifyNever(() => repo.reinitialiser(any(), any(), any())),
  );

  test('le compte lit prénom, nom et téléphone, et affiche le nom complet', () {
    final u = UserModel.fromJson({
      'id': 1,
      'email': 'awa@example.com',
      'first_name': 'Awa',
      'last_name': 'Diop',
      'phone': '+221 77 000 00 00',
      'plan': 'free',
      'pro_until': null,
      'assistant': {'used': 0, 'limit': 3},
    });
    expect(u.nomAffiche, 'Awa Diop');
    expect(u.telephone, '+221 77 000 00 00');

    final sansNom = UserModel.fromJson({
      'id': 2,
      'email': 'b@example.com',
      'plan': 'free',
      'assistant': {'used': 0, 'limit': 3},
    });
    expect(sansNom.nomAffiche, 'b@example.com');
  });
}
