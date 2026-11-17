import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/analysis/domain/entities/analysis.dart';
import 'package:financial_ai_advisor/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:financial_ai_advisor/features/analysis/domain/usecases/ask_assistant.dart';
import 'package:financial_ai_advisor/features/analysis/presentation/bloc/assistant_bloc.dart';
import 'package:financial_ai_advisor/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AnalysisRepository {}

const _quota = Quota(utilisees: 1, limite: 3);

void main() {
  late _Repo repo;

  setUp(() => repo = _Repo());

  AssistantBloc bloc() => AssistantBloc(askAssistant: AskAssistant(repo), symbol: 'PALM_CI');

  void repondre(List<Either<Failure, EvenementAssistant>> flux) =>
      when(() => repo.demander(any(), any())).thenAnswer((_) => Stream.fromIterable(flux));

  List<String> contenus(AssistantState s) => s.messages.map((m) => m.contenu).toList();

  blocTest<AssistantBloc, AssistantState>(
    'affiche la réponse pendant qu’elle s’écrit, puis le quota',
    setUp: () => repondre(const [
      Right(MorceauAssistant('Le RSI')),
      Right(MorceauAssistant(' est neutre.')),
      Right(FinAssistant(_quota)),
    ]),
    build: bloc,
    act: (b) => b.add(QuestionPosee('Que dit le RSI ?')),
    expect: () => [
      isA<AssistantState>()
          .having(contenus, 'messages', ['Que dit le RSI ?'])
          .having((s) => s.enCours, 'enCours', true),
      isA<AssistantState>().having(contenus, 'messages', ['Que dit le RSI ?', 'Le RSI']),
      isA<AssistantState>().having(contenus, 'messages', ['Que dit le RSI ?', 'Le RSI est neutre.']),
      isA<AssistantState>()
          .having(contenus, 'messages', ['Que dit le RSI ?', 'Le RSI est neutre.'])
          .having((s) => s.enCours, 'enCours', false)
          .having((s) => s.quota, 'quota', _quota),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'une réponse interrompue retire la question et sa réponse partielle',
    setUp: () => repondre(const [
      Right(MorceauAssistant('Le début')),
      Left(ServerFailure(errorMessage: 'L’assistant n’a pas pu répondre.')),
    ]),
    build: bloc,
    act: (b) => b.add(QuestionPosee('Pourquoi ce signal ?')),
    skip: 2,
    expect: () => [
      isA<AssistantState>()
          .having((s) => s.messages, 'messages', isEmpty)
          .having((s) => s.enCours, 'enCours', false)
          .having((s) => s.erreur, 'erreur', 'L’assistant n’a pas pu répondre.'),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'une question vide n’est pas envoyée',
    build: bloc,
    act: (b) => b.add(QuestionPosee('   ')),
    expect: () => <AssistantState>[],
    verify: (_) => verifyNever(() => repo.demander(any(), any())),
  );
}
