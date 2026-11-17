import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financial_ai_advisor/core/errors/failure.dart';
import 'package:financial_ai_advisor/features/alerts/data/models/alertes_model.dart';
import 'package:financial_ai_advisor/features/alerts/domain/entities/alerte.dart';
import 'package:financial_ai_advisor/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:financial_ai_advisor/features/alerts/domain/usecases/alerts_usecases.dart';
import 'package:financial_ai_advisor/features/alerts/presentation/bloc/alerts_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AlertsRepository {}

const _signal = Alerte(
  id: 'signal:PALM_CI:2026-11-16',
  type: TypeAlerte.signal,
  symbol: 'PALM_CI',
  nom: 'PALM CI',
  date: '2026-11-16',
  nonLue: true,
  avant: 'CONSERVER',
  apres: 'ACHETER',
);

const _nonLue = Alertes(liste: [_signal], nonLues: 1);
final _lue = Alertes(liste: [
  Alerte(
    id: _signal.id,
    type: _signal.type,
    symbol: _signal.symbol,
    nom: _signal.nom,
    date: _signal.date,
    avant: _signal.avant,
    apres: _signal.apres,
  ),
], nonLues: 0);

void main() {
  test('lit les alertes de signal et de dividende', () {
    final a = AlertesModel.fromJson({
      'alerts': [
        {
          'id': 'dividend:BIBI_CI:2026-11-16',
          'kind': 'dividend',
          'symbol': 'BIBI_CI',
          'name': 'BIBI CI',
          'date': '2026-11-16',
          'held': true,
          'unread': true,
          'amount': 500,
          'cutoff': '2026-11-20',
          'days_left': 4,
        },
        {
          'id': 'signal:PALM_CI:2026-11-13',
          'kind': 'signal',
          'symbol': 'PALM_CI',
          'name': 'PALM CI',
          'date': '2026-11-13',
          'held': false,
          'unread': false,
          'before': 'CONSERVER',
          'after': 'ACHETER',
        },
      ],
      'unread': 1,
    });
    expect(a.nonLues, 1);
    expect(a.liste.first.type, TypeAlerte.dividende);
    expect(a.liste.first.montant, 500);
    expect(a.liste.first.detenu, isTrue);
    expect(a.liste.last.type, TypeAlerte.signal);
    expect(a.liste.last.apres, 'ACHETER');
  });

  late _Repo repo;
  setUp(() => repo = _Repo());
  AlertsBloc bloc() => AlertsBloc(getAlertes: GetAlertes(repo), marquerLues: MarquerAlertesLues(repo));

  blocTest<AlertsBloc, AlertsState>(
    'ouvrir l’écran remet le compteur à zéro et garde les nouvelles en avant',
    setUp: () => when(() => repo.marquerLues()).thenAnswer((_) async => Right(_lue)),
    build: bloc,
    seed: () => AlertsLoaded(_nonLue),
    act: (b) => b.add(AlertesVues()),
    expect: () => [
      isA<AlertsLoaded>()
          .having((s) => s.alertes.nonLues, 'nonLues', 0)
          .having((s) => s.nouvelles, 'nouvelles', {_signal.id}),
    ],
  );

  blocTest<AlertsBloc, AlertsState>(
    'rien à marquer quand tout est déjà lu',
    build: bloc,
    seed: () => AlertsLoaded(_lue),
    act: (b) => b.add(AlertesVues()),
    expect: () => <AlertsState>[],
    verify: (_) => verifyNever(() => repo.marquerLues()),
  );

  blocTest<AlertsBloc, AlertsState>(
    'erreur de chargement affichée',
    setUp: () => when(() => repo.getAlertes())
        .thenAnswer((_) async => const Left(ServerFailure(errorMessage: 'Serveur injoignable'))),
    build: bloc,
    act: (b) => b.add(LoadAlertes()),
    expect: () => [isA<AlertsLoading>(), isA<AlertsError>()],
  );
}
