import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:financial_ai_advisor/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:financial_ai_advisor/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements FavoritesRepository {}

void main() {
  late _Repo repo;
  setUp(() => repo = _Repo());
  FavoritesBloc bloc() => FavoritesBloc(getFavoris: GetFavoris(repo), changerFavori: ChangerFavori(repo));

  List<String> symboles(FavoritesState s) => s.symboles;

  blocTest<FavoritesBloc, FavoritesState>(
    'l’étoile s’allume tout de suite, puis la liste du serveur fait foi',
    setUp: () => when(() => repo.ajouter('PALM_CI')).thenAnswer((_) async => const Right(['BIBI_CI', 'PALM_CI'])),
    build: bloc,
    seed: () => const FavoritesState(symboles: ['BIBI_CI']),
    act: (b) => b.add(BasculerFavori('PALM_CI')),
    expect: () => [
      isA<FavoritesState>().having(symboles, 'symboles', ['BIBI_CI', 'PALM_CI']),
      isA<FavoritesState>().having(symboles, 'symboles', ['BIBI_CI', 'PALM_CI']),
    ],
  );

  blocTest<FavoritesBloc, FavoritesState>(
    'un retrait refusé remet l’étoile et affiche le message',
    setUp: () => when(() => repo.retirer('BIBI_CI'))
        .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Serveur injoignable'))),
    build: bloc,
    seed: () => const FavoritesState(symboles: ['BIBI_CI']),
    act: (b) => b.add(BasculerFavori('BIBI_CI')),
    expect: () => [
      isA<FavoritesState>().having(symboles, 'symboles', <String>[]),
      isA<FavoritesState>()
          .having(symboles, 'symboles', ['BIBI_CI'])
          .having((s) => s.erreur, 'erreur', 'Serveur injoignable'),
    ],
  );

  blocTest<FavoritesBloc, FavoritesState>(
    'la déconnexion vide les favoris',
    build: bloc,
    seed: () => const FavoritesState(symboles: ['BIBI_CI']),
    act: (b) => b.add(ViderFavoris()),
    expect: () => [isA<FavoritesState>().having(symboles, 'symboles', <String>[])],
  );
}
