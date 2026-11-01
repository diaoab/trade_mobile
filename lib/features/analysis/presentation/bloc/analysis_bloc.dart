import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/analysis.dart';
import '../../domain/usecases/get_analysis.dart';

abstract class AnalysisEvent {}

class LoadAnalysis extends AnalysisEvent {
  final String symbol;
  LoadAnalysis(this.symbol);
}

abstract class AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final Analysis analyse;
  AnalysisLoaded(this.analyse);
}

class AnalysisError extends AnalysisState {
  final String message;
  AnalysisError(this.message);
}

/// Analyse d'un titre : un bloc par écran (créé par la route).
class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final GetAnalysis getAnalysis;

  AnalysisBloc({required this.getAnalysis}) : super(AnalysisLoading()) {
    on<LoadAnalysis>((event, emit) async {
      if (state is! AnalysisLoaded) emit(AnalysisLoading());
      final result = await getAnalysis(event.symbol);
      result.fold((f) => emit(AnalysisError(f.errorMessage)), (a) => emit(AnalysisLoaded(a)));
    });
  }
}
