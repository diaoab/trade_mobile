import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_market.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetMarket getMarket;

  MarketBloc({required this.getMarket}) : super(MarketInitial()) {
    on<LoadMarket>(_onLoad);
  }

  Future<void> _onLoad(LoadMarket event, Emitter<MarketState> emit) async {
    // Actualisation : la liste reste affichée pendant le chargement.
    if (state is! MarketLoaded) emit(MarketLoading());
    final result = await getMarket();
    result.fold((f) => emit(MarketError(f.errorMessage)), (titres) => emit(MarketLoaded(titres)));
  }
}
