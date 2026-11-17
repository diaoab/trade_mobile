import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/bandeau_cours_anciens.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/connexion_requise.dart';
import '../../../favorites/presentation/widgets/bouton_favori.dart';
import '../../domain/entities/analysis.dart';
import '../bloc/analysis_bloc.dart';
import '../bloc/assistant_bloc.dart';
import '../widgets/assistant_section.dart';
import '../widgets/indicator_row.dart';
import '../widgets/price_chart.dart';
import '../widgets/signal_panel.dart';
import '../widgets/simulateur_section.dart';

/// Analyse détaillée d'un titre. Ses blocs vivent le temps de l'écran.
class AnalysisPage extends StatelessWidget {
  final String symbol;
  const AnalysisPage({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AnalysisBloc>()..add(LoadAnalysis(symbol))),
        BlocProvider(
          create: (_) => AssistantBloc(
            askAssistant: sl(),
            symbol: symbol,
            quota: auth is Authenticated ? auth.user.assistant : null,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 44,
          actions: [BoutonFavori(symbol: symbol, nom: symbol.replaceAll('_', ' ')), const SizedBox(width: 8)],
        ),
        body: BlocBuilder<AnalysisBloc, AnalysisState>(
          builder: (context, state) => AppEcran(
            onActualiser: () async {
              final bloc = context.read<AnalysisBloc>()..add(LoadAnalysis(symbol));
              await bloc.stream.firstWhere((s) => s is! AnalysisLoading);
            },
            enfants: switch (state) {
              AnalysisLoaded(:final analyse) => _contenu(context, analyse),
              AnalysisError(:final message) => [MessageErreur(message)],
              _ => const [Chargement()],
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _contenu(BuildContext context, Analysis a) {
    final c = context.couleurs;
    final details = a.resultat.details.where((d) => d.indicateur != 'Modèle').toList();
    final dividende = a.dividende;
    final probabilite = a.prediction.probabiliteHausse;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACTION · BRVM', style: AppTypo.style(taille: 13, graisse: FontWeight.w600, couleur: c.texteMoyen, interlettre: 0.4)),
            const SizedBox(height: 2),
            Text(a.nom, style: AppTypo.style(taille: 28, graisse: FontWeight.w700, couleur: c.texte, interlettre: -0.5)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: Format.nombre(a.cours)),
                TextSpan(text: ' FCFA', style: AppTypo.style(taille: 17, graisse: FontWeight.w500, couleur: c.texteMoyen)),
              ]),
              style: AppTypo.style(taille: 34, graisse: FontWeight.w600, couleur: c.texte, interlettre: -0.8, tabulaire: true),
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: Format.pourcentage(a.variation)),
                TextSpan(
                    text: '  séance du ${Format.date(a.seance)}',
                    style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
              ]),
              style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.variation(a.variation), tabulaire: true),
            ),
          ],
        ),
      ),
      BandeauCoursAnciens(date: a.seance, portee: 'Le cours, le graphique et le signal'),
      const SizedBox(height: 20),
      PriceChart(graphique: a.graphique),
      const SizedBox(height: 28),
      SignalPanel(resultat: a.resultat),
      AppSection(
        titre: 'Détail par indicateur',
        action: Text('${a.resultat.positifs} ↑ · ${a.resultat.negatifs} ↓ · ${a.resultat.neutres} =',
            style: AppTypo.style(taille: 13, couleur: c.texteFaible, tabulaire: true)),
        enfants: [
          for (var i = 0; i < details.length; i++) IndicatorRow(detail: details[i], derniere: i == details.length - 1),
          for (final alerte in a.resultat.alertesLiquidite)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_outlined, size: 16, color: c.prudence),
                  const SizedBox(width: AppEspace.s),
                  Expanded(child: Text(alerte, style: AppTypo.style(taille: 14, couleur: c.prudence, hauteur: 1.4))),
                ],
              ),
            ),
        ],
      ),
      AppSection(
        titre: 'Modèle statistique',
        enfants: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
            child: probabilite == null
                ? const TexteDiscret('Indisponible pour cette séance : le signal repose sur l’analyse technique seule.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: '${Format.nombre(probabilite * 100)} %',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(
                            text: ' de probabilité de surperformance'
                                '${a.prediction.horizonJours != null ? ' à ${a.prediction.horizonJours} séances' : ''}',
                            style: TextStyle(color: c.texteMoyen),
                          ),
                        ]),
                        style: AppTypo.style(taille: 17, couleur: c.texte, tabulaire: true),
                      ),
                      if (!a.prediction.compte) ...[
                        const SizedBox(height: 6),
                        const TexteDiscret(
                            'Indicatif : le modèle ne fait pas encore mieux qu’une référence naïve et n’entre pas dans le score.'),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      if (dividende != null)
        AppSection(
          titre: 'Prochain dividende',
          enfants: [
            GrilleStats(elements: [
              ElementStat('Montant par action', '${Format.nombre(dividende.montant)} FCFA'),
              ElementStat('Détachement', Format.dateCourte(dividende.detachement)),
              ElementStat('Acheter au plus tard', Format.dateCourte(dividende.dateButoir)),
              ElementStat('Délai', '${dividende.joursRestants} j'),
            ]),
          ],
        ),
      SimulateurSection(analyse: a),
      if (estInvite(context))
        const AppSection(
          titre: 'Assistant',
          enfants: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
              child: _AssistantInvite(),
            ),
          ],
        )
      else
        const AssistantSection(),
      const NotePied(kAvertissement),
    ];
  }
}

/// Assistant réservé aux comptes : le visiteur en démo est invité à en créer un.
class _AssistantInvite extends StatelessWidget {
  const _AssistantInvite();

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => demanderConnexion(context, raison: 'poser vos questions à l’assistant sur cette analyse'),
        child: Padding(
          padding: const EdgeInsets.all(AppEspace.l),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: c.texteMoyen),
              const SizedBox(width: AppEspace.m),
              Expanded(
                child: Text('Posez vos questions sur cette analyse avec un compte gratuit.',
                    style: AppTypo.style(taille: 15, couleur: c.texte, hauteur: 1.4)),
              ),
              Icon(Icons.chevron_right, color: c.texteFaible),
            ],
          ),
        ),
      ),
    );
  }
}
