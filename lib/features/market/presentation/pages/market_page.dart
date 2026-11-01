import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/market_entry.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/sparkline.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        final bloc = context.read<MarketBloc>();
        final derniere = state is MarketLoaded ? state.derniereSeance : null;
        return AppEcran(
          titre: 'Marché',
          sousTitre: derniere == null ? 'BRVM' : 'BRVM · séance du ${Format.date(derniere)}',
          onActualiser: () async {
            bloc.add(LoadMarket());
            await bloc.stream.firstWhere((s) => s is! MarketLoading);
          },
          enfants: [
            if (state is MarketError) MessageErreur(state.message),
            if (state is MarketLoading || state is MarketInitial) const Chargement(),
            if (state is MarketLoaded) ...[
              if (state.titres.isNotEmpty) _Repartition(titres: state.titres),
              AppSection(
                titre: 'Titres suivis',
                enfants: [
                  if (state.titres.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
                      child: TexteDiscret('Aucun titre disponible.'),
                    ),
                  for (var i = 0; i < state.titres.length; i++)
                    _LigneTitre(titre: state.titres[i], derniere: i == state.titres.length - 1),
                ],
              ),
              if (state.titres.any((t) => t.changements.isNotEmpty)) _Changements(titres: state.titres),
            ],
            const NotePied('Cours en FCFA, clôture de la dernière séance connue. $kAvertissement'),
          ],
        );
      },
    );
  }
}

/// Répartition des signaux : barre achat / conserver / vente.
class _Repartition extends StatelessWidget {
  final List<MarketEntry> titres;
  const _Repartition({required this.titres});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final comptes = {for (final s in Signal.values) s: titres.where((t) => t.decision == s.code).length};
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.m, AppEspace.gouttiere, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: c.surface,
              child: Row(
                children: [
                  for (final s in Signal.values)
                    if (comptes[s]! > 0)
                      Expanded(
                        flex: comptes[s]!,
                        child: Container(margin: const EdgeInsets.only(right: 2), color: s.couleur(c)),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppEspace.s),
          Wrap(
            spacing: AppEspace.l,
            children: [
              for (final s in Signal.values)
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${comptes[s]} ',
                      style: AppTypo.style(taille: 13, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true)),
                  TextSpan(text: s.libelle.toLowerCase(), style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
                ])),
            ],
          ),
        ],
      ),
    );
  }
}

class _LigneTitre extends StatelessWidget {
  final MarketEntry titre;
  final bool derniere;
  const _LigneTitre({required this.titre, required this.derniere});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final dividende = titre.dividende;
    return AppLigne(
      derniere: derniere,
      onTap: () => Navigator.of(context).pushNamed(AppRouter.analyseRoute, arguments: titre.symbol),
      enfants: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte, interlettre: -0.2)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SignalTag(decision: titre.decision),
                  if (dividende != null && dividende.joursRestants <= 7)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.event_outlined, size: 12, color: c.prudence),
                      const SizedBox(width: 3),
                      Text('Dividende J−${dividende.joursRestants}',
                          style: AppTypo.style(taille: 12, graisse: FontWeight.w500, couleur: c.prudence)),
                    ]),
                ],
              ),
            ],
          ),
        ),
        Sparkline(valeurs: titre.spark),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Format.nombre(titre.cours),
                style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true)),
            const SizedBox(height: 4),
            ChangePill(valeur: titre.variation),
          ],
        ),
      ],
    );
  }
}

class _Changements extends StatelessWidget {
  final List<MarketEntry> titres;
  const _Changements({required this.titres});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final avecChangements = titres.where((t) => t.changements.isNotEmpty).toList();
    return AppSection(
      titre: 'Depuis la dernière séance',
      enfants: [
        for (var i = 0; i < avecChangements.length; i++)
          AppLigne(
            derniere: i == avecChangements.length - 1,
            enfants: [
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: avecChangements[i].nom,
                      style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.texte)),
                  TextSpan(
                      text: ' — ${avecChangements[i].changements.join(', ')}',
                      style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
                ])),
              ),
            ],
          ),
      ],
    );
  }
}
