import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/core/utils/format.dart';
import 'package:financial_ai_advisor/features/account/data/models/preferences_model.dart';
import 'package:financial_ai_advisor/features/account/domain/entities/preferences.dart';
import 'package:financial_ai_advisor/features/auth/data/models/user_model.dart';
import 'package:financial_ai_advisor/features/market/domain/entities/market_entry.dart';
import 'package:financial_ai_advisor/features/market/domain/repositories/market_repository.dart';
import 'package:financial_ai_advisor/features/market/domain/usecases/get_market.dart';
import 'package:financial_ai_advisor/features/market/domain/usecases/rafraichir_cours.dart';
import 'package:financial_ai_advisor/features/market/presentation/bloc/market_bloc.dart';
import 'package:financial_ai_advisor/features/market/presentation/bloc/market_event.dart';
import 'package:financial_ai_advisor/features/market/presentation/bloc/market_state.dart';
import 'package:financial_ai_advisor/features/portfolio/data/models/portfolio_model.dart';
import 'package:financial_ai_advisor/features/portfolio/domain/entities/portfolio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements MarketRepository {}

const _palm = MarketEntry(symbol: 'PALM_CI', nom: 'PALM CI', cours: 7500, date: '2026-11-17');

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  test('un achat n’envoie que le titre et la quantité (prix et date fixés par le serveur)', () {
    expect(const NouvellePosition(symbol: 'PALM_CI', quantite: 10).toJson(), {'symbol': 'PALM_CI', 'quantity': 10.0});
  });

  test('le compte lit le mot de passe provisoire et les limites de l’offre', () {
    final u = UserModel.fromJson({
      'id': 1,
      'email': 'a@b.c',
      'plan': 'free',
      'assistant': {'used': 0, 'limit': 3},
      'must_change_password': true,
      'limits': {'positions': 5, 'favorites': 5},
    });
    expect(u.doitChangerMotDePasse, isTrue);
    expect(u.limites.positions, 5);

    final ancien = UserModel.fromJson({'id': 1, 'email': 'a@b.c', 'plan': 'pro', 'assistant': {'used': 0, 'limit': 50}});
    expect(ancien.doitChangerMotDePasse, isFalse);
    expect(ancien.limites.positions, isNull);
  });

  test('réglages de notifications : lus, tout actif par défaut, modification partielle', () {
    final base = {'selected_parameters': <String>[], 'adjust_dividends': true, 'round_trip_fee': 2, 'indicator_options': <String>[]};
    expect(PreferencesModel.fromJson(base).notifications, const ReglagesNotifications());
    final p = PreferencesModel.fromJson({
      ...base,
      'notifications': {'enabled': true, 'buy': false, 'sell': true, 'dividend': true},
    });
    expect(p.notifications.achat, isFalse);
    expect(const ModificationPreferences(notifications: {'sell': false}).toJson(), {
      'notifications': {'sell': false},
    });
  });

  group('Récupérer les cours du jour', () {
    late _Repo repo;
    setUp(() => repo = _Repo());

    MarketBloc bloc() => MarketBloc(getMarket: GetMarket(repo), rafraichirCours: RafraichirCours(repo));

    blocTest<MarketBloc, MarketState>(
      'récupère, recharge le Marché et annonce la séance',
      setUp: () {
        when(() => repo.rafraichirCours()).thenAnswer((_) async => const Right('2026-11-17'));
        when(() => repo.getMarket()).thenAnswer((_) async => const Right([_palm]));
      },
      build: bloc,
      seed: () => MarketLoaded(const []),
      act: (b) => b.add(RecupererCoursDuJour()),
      verify: (b) {
        final s = b.state as MarketLoaded;
        expect(s.titres, [_palm]);
        expect(s.recuperation, isFalse);
        expect(s.message, 'Cours à jour : séance du ${Format.date('2026-11-17')}.');
      },
    );

    blocTest<MarketBloc, MarketState>(
      'une erreur de récupération garde la liste et affiche le message',
      setUp: () {
        when(() => repo.rafraichirCours()).thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Cours du jour indisponibles')));
        when(() => repo.getMarket()).thenAnswer((_) async => const Right([_palm]));
      },
      build: bloc,
      seed: () => MarketLoaded(const [_palm]),
      act: (b) => b.add(RecupererCoursDuJour()),
      verify: (b) => expect((b.state as MarketLoaded).message, 'Cours du jour indisponibles'),
    );
  });
}
