import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/format.dart';
import '../../domain/usecases/get_market.dart';
import '../../domain/usecases/rafraichir_cours.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetMarket getMarket;
  final RafraichirCours? rafraichirCours;

  MarketBloc({required this.getMarket, this.rafraichirCours}) : super(MarketInitial()) {
    on<LoadMarket>(_onLoad);
    on<RecupererCoursDuJour>(_onRecuperer);
  }

  Future<void> _onLoad(LoadMarket event, Emitter<MarketState> emit) async {
    // Actualisation : la liste reste affichée pendant le chargement.
    if (state is! MarketLoaded) emit(MarketLoading());
    final result = await getMarket();
    result.fold((f) => emit(MarketError(f.errorMessage)), (titres) => emit(MarketLoaded(titres)));
  }

  Future<void> _onRecuperer(RecupererCoursDuJour event, Emitter<MarketState> emit) async {
    final avant = state is MarketLoaded ? (state as MarketLoaded).titres : const <dynamic>[];
    if (rafraichirCours == null) return;
    if (state is MarketLoaded) emit(MarketLoaded((state as MarketLoaded).titres, recuperation: true));
    final result = await rafraichirCours!();
    final message = result.fold(
      (f) => f.errorMessage,
      (date) => date == null ? 'Cours du jour récupérés.' : 'Cours à jour : séance du ${Format.date(date)}.',
    );
    final marche = await getMarket();
    marche.fold(
      (f) => emit(avant.isEmpty ? MarketError(f.errorMessage) : MarketLoaded(List.from(avant), message: message)),
      (titres) => emit(MarketLoaded(titres, message: message)),
    );
  }
}
