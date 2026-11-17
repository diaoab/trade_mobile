import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/analysis.dart';
import '../../domain/usecases/ask_assistant.dart';

abstract class AssistantEvent {}

class QuestionPosee extends AssistantEvent {
  final String question;
  QuestionPosee(this.question);
}

class AssistantState {
  final List<MessageAssistant> messages;
  final bool enCours;
  final String? erreur;
  final Quota? quota;

  const AssistantState({this.messages = const [], this.enCours = false, this.erreur, this.quota});

  AssistantState copyWith({List<MessageAssistant>? messages, bool? enCours, String? erreur, Quota? quota}) =>
      AssistantState(
        messages: messages ?? this.messages,
        enCours: enCours ?? this.enCours,
        erreur: erreur,
        quota: quota ?? this.quota,
      );
}

/// Conversation avec l'assistant sur l'analyse affichée.
class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final AskAssistant askAssistant;
  final String symbol;

  AssistantBloc({required this.askAssistant, required this.symbol, Quota? quota})
      : super(AssistantState(quota: quota)) {
    on<QuestionPosee>(_onQuestion);
  }

  Future<void> _onQuestion(QuestionPosee event, Emitter<AssistantState> emit) async {
    final question = event.question.trim();
    if (question.isEmpty || state.enCours) return;
    final avant = state.messages;
    final messages = [...avant, MessageAssistant(role: 'user', contenu: question)];
    emit(state.copyWith(messages: messages, enCours: true));

    // La réponse s'affiche pendant qu'elle s'écrit.
    var reponse = '';
    List<MessageAssistant> avecReponse() => [...messages, MessageAssistant(role: 'assistant', contenu: reponse)];

    await emit.forEach(
      askAssistant(symbol, messages),
      onData: (resultat) => resultat.fold(
        // La question refusée (ou interrompue) est retirée avec sa réponse
        // partielle : on peut la reposer telle quelle, le quota est rendu.
        (f) => state.copyWith(messages: avant, enCours: false, erreur: f.errorMessage),
        (evenement) {
          switch (evenement) {
            case MorceauAssistant(:final texte):
              reponse += texte;
              return state.copyWith(messages: avecReponse());
            case FinAssistant(:final quota):
              return state.copyWith(messages: avecReponse(), enCours: false, quota: quota);
          }
        },
      ),
    );
  }
}
