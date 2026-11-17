import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alerte.dart';
import '../../domain/usecases/alerts_usecases.dart';

abstract class AlertsEvent {}

class LoadAlertes extends AlertsEvent {}

/// Écran des alertes ouvert : tout ce qui y est affiché devient lu.
class AlertesVues extends AlertsEvent {}

abstract class AlertsState {}

class AlertsInitial extends AlertsState {}

class AlertsLoading extends AlertsState {}

class AlertsLoaded extends AlertsState {
  final Alertes alertes;

  /// Liste telle qu'à l'ouverture de l'écran : les alertes alors non lues
  /// restent mises en avant même après les avoir marquées lues.
  final Set<String> nouvelles;

  AlertsLoaded(this.alertes, {Set<String>? nouvelles})
      : nouvelles = nouvelles ?? {for (final a in alertes.liste) if (a.nonLue) a.id};
}

class AlertsError extends AlertsState {
  final String message;
  AlertsError(this.message);
}

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetAlertes getAlertes;
  final MarquerAlertesLues marquerLues;

  AlertsBloc({required this.getAlertes, required this.marquerLues}) : super(AlertsInitial()) {
    on<LoadAlertes>(_onLoad);
    on<AlertesVues>(_onVues);
  }

  Future<void> _onLoad(LoadAlertes event, Emitter<AlertsState> emit) async {
    if (state is! AlertsLoaded) emit(AlertsLoading());
    final result = await getAlertes();
    result.fold((f) => emit(AlertsError(f.errorMessage)), (a) => emit(AlertsLoaded(a)));
  }

  Future<void> _onVues(AlertesVues event, Emitter<AlertsState> emit) async {
    final actuel = state;
    if (actuel is! AlertsLoaded || actuel.alertes.nonLues == 0) return;
    final result = await marquerLues();
    // Échec : le compteur reste, l'écran garde la liste.
    result.fold((_) {}, (a) => emit(AlertsLoaded(a, nouvelles: actuel.nouvelles)));
  }
}
