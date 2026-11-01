import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/entities/portfolio.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/usecases/add_position.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/usecases/delete_position.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/usecases/get_portfolio.dart';
import 'package:financial_ai_advisor/features/portfolio/presentation/bloc/portfolio_bloc.dart';
import 'package:financial_ai_advisor/features/portfolio/presentation/bloc/portfolio_event.dart';
import 'package:financial_ai_advisor/features/portfolio/presentation/bloc/portfolio_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements PortfolioRepository {}

const _vide = Portfolio(positions: [], totaux: TotauxPortefeuille(cout: 0, valeur: 0, dividendes: 0, frais: 0, net: 0));
final _saisie = NouvellePosition(symbol: 'PALM_CI', quantite: 10, prixAchat: 7000, dateAchat: DateTime(2026, 1, 5));

void main() {
  late _Repo repo;

  setUpAll(() => registerFallbackValue(_saisie));
  setUp(() => repo = _Repo());

  PortfolioBloc bloc() =>
      PortfolioBloc(getPortfolio: GetPortfolio(repo), addPosition: AddPosition(repo), deletePosition: DeletePosition(repo));

  blocTest<PortfolioBloc, PortfolioState>(
    'un ajout réussi incrémente le compteur (ferme le formulaire)',
    setUp: () => when(() => repo.ajouter(any())).thenAnswer((_) async => const Right(_vide)),
    build: bloc,
    seed: () => PortfolioLoaded(_vide),
    act: (b) => b.add(PositionAdded(_saisie)),
    expect: () => [isA<PortfolioLoaded>().having((s) => s.ajouts, 'ajouts', 1)],
  );

  blocTest<PortfolioBloc, PortfolioState>(
    'un ajout refusé garde le portefeuille et affiche le message',
    setUp: () => when(() => repo.ajouter(any()))
        .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Titre inconnu'))),
    build: bloc,
    seed: () => PortfolioLoaded(_vide),
    act: (b) => b.add(PositionAdded(_saisie)),
    expect: () => [
      isA<PortfolioLoaded>().having((s) => s.erreurAction, 'erreur', 'Titre inconnu').having((s) => s.ajouts, 'ajouts', 0),
    ],
  );
}
