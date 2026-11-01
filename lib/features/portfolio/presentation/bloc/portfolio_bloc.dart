import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_position.dart';
import '../../domain/usecases/delete_position.dart';
import '../../domain/usecases/get_portfolio.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolio getPortfolio;
  final AddPosition addPosition;
  final DeletePosition deletePosition;

  PortfolioBloc({required this.getPortfolio, required this.addPosition, required this.deletePosition})
      : super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoad);
    on<PositionAdded>(_onAdd);
    on<PositionDeleted>(_onDelete);
  }

  int get _ajouts => state is PortfolioLoaded ? (state as PortfolioLoaded).ajouts : 0;

  Future<void> _onLoad(LoadPortfolio event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoaded) emit(PortfolioLoading());
    final result = await getPortfolio();
    result.fold((f) => emit(PortfolioError(f.errorMessage)), (p) => emit(PortfolioLoaded(p, ajouts: _ajouts)));
  }

  Future<void> _onAdd(PositionAdded event, Emitter<PortfolioState> emit) async {
    final result = await addPosition(event.position);
    result.fold(
      (f) => _erreurAction(emit, f.errorMessage),
      (p) => emit(PortfolioLoaded(p, ajouts: _ajouts + 1)),
    );
  }

  Future<void> _onDelete(PositionDeleted event, Emitter<PortfolioState> emit) async {
    final result = await deletePosition(event.id);
    result.fold((f) => _erreurAction(emit, f.errorMessage), (p) => emit(PortfolioLoaded(p, ajouts: _ajouts)));
  }

  void _erreurAction(Emitter<PortfolioState> emit, String message) {
    final actuel = state;
    emit(actuel is PortfolioLoaded
        ? PortfolioLoaded(actuel.portfolio, erreurAction: message, ajouts: actuel.ajouts)
        : PortfolioError(message));
  }
}
