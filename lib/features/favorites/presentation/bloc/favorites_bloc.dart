import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/favorites_usecases.dart';

abstract class FavoritesEvent {}

class LoadFavoris extends FavoritesEvent {}

/// Déconnexion : rien du compte précédent ne reste.
class ViderFavoris extends FavoritesEvent {}

class BasculerFavori extends FavoritesEvent {
  final String symbol;
  BasculerFavori(this.symbol);
}

class FavoritesState {
  /// Dans l'ordre d'ajout.
  final List<String> symboles;
  final String? erreur;

  const FavoritesState({this.symboles = const [], this.erreur});

  bool contient(String symbol) => symboles.contains(symbol);
}

/// Favoris du compte, partagés par le Marché et l'écran Analyse (fourni à la
/// racine de l'app). Le changement s'affiche tout de suite ; s'il échoue, la
/// liste revient à son état précédent avec un message.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoris getFavoris;
  final ChangerFavori changerFavori;

  FavoritesBloc({required this.getFavoris, required this.changerFavori}) : super(const FavoritesState()) {
    on<LoadFavoris>(_onLoad);
    on<ViderFavoris>((_, emit) => emit(const FavoritesState()));
    on<BasculerFavori>(_onBasculer);
  }

  Future<void> _onLoad(LoadFavoris event, Emitter<FavoritesState> emit) async {
    final result = await getFavoris();
    result.fold((f) => emit(FavoritesState(symboles: state.symboles, erreur: f.errorMessage)),
        (liste) => emit(FavoritesState(symboles: liste)));
  }

  Future<void> _onBasculer(BasculerFavori event, Emitter<FavoritesState> emit) async {
    final avant = state.symboles;
    final suivre = !avant.contains(event.symbol);
    emit(FavoritesState(symboles: suivre ? [...avant, event.symbol] : avant.where((s) => s != event.symbol).toList()));
    final result = await changerFavori(event.symbol, suivre: suivre);
    result.fold((f) => emit(FavoritesState(symboles: avant, erreur: f.errorMessage)),
        (liste) => emit(FavoritesState(symboles: liste)));
  }
}
