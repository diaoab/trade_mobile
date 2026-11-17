import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/alerte.dart';
import '../bloc/alerts_bloc.dart';

/// Ouvre l'écran des alertes avec le bloc de l'accueil (le compteur de la
/// cloche se remet à zéro au retour).
void ouvrirAlertes(BuildContext context) {
  final bloc = context.read<AlertsBloc>();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocProvider.value(value: bloc, child: const AlertsPage()),
  ));
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AlertsBloc>().add(AlertesVues());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 44),
      body: BlocBuilder<AlertsBloc, AlertsState>(
        builder: (context, state) => AppEcran(
          titre: 'Alertes',
          onActualiser: () async {
            final bloc = context.read<AlertsBloc>()..add(LoadAlertes());
            await bloc.stream.firstWhere((s) => s is! AlertsLoading);
            bloc.add(AlertesVues());
          },
          enfants: [
            if (state is AlertsError) MessageErreur(state.message),
            if (state is AlertsLoading || state is AlertsInitial) const Chargement(),
            if (state is AlertsLoaded && state.alertes.liste.isEmpty)
              const EtatVide(
                icone: Icons.notifications_none,
                titre: 'Aucune alerte',
                texte: 'Vous serez prévenu ici quand un signal change ou qu’un dividende de vos titres approche.',
              ),
            if (state is AlertsLoaded && state.alertes.liste.isNotEmpty)
              AppSection(
                enfants: [
                  for (var i = 0; i < state.alertes.liste.length; i++)
                    _LigneAlerte(
                      alerte: state.alertes.liste[i],
                      nouvelle: state.nouvelles.contains(state.alertes.liste[i].id),
                      derniere: i == state.alertes.liste.length - 1,
                    ),
                ],
              ),
            const NotePied('Changements de signal des 10 dernières séances, sur vos favoris et les titres de votre '
                'portefeuille (sur tous les titres tant que vous n’en avez pas). '
                'Dividendes : titres de votre portefeuille, dans les 7 jours avant la date butoir d’achat.'),
          ],
        ),
      ),
    );
  }
}

class _LigneAlerte extends StatelessWidget {
  final Alerte alerte;
  final bool nouvelle;
  final bool derniere;

  const _LigneAlerte({required this.alerte, required this.nouvelle, required this.derniere});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final signal = alerte.type == TypeAlerte.signal;
    return AppLigne(
      derniere: derniere,
      onTap: () => Navigator.of(context).pushNamed(AppRouter.analyseRoute, arguments: alerte.symbol),
      enfants: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(signal ? Icons.swap_vert : Icons.event_outlined, size: 22, color: signal ? c.texte : c.prudence),
            if (nouvelle)
              Positioned(
                left: -12,
                top: 7,
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.serie1, shape: BoxShape.circle)),
              ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                signal ? '${alerte.nom} change de signal' : 'Dividende ${alerte.nom}',
                style: AppTypo.style(taille: 15, graisse: nouvelle ? FontWeight.w700 : FontWeight.w600, couleur: c.texte),
              ),
              const SizedBox(height: 4),
              if (signal)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    SignalTag(decision: alerte.avant),
                    Icon(Icons.arrow_forward, size: 14, color: c.texteMoyen),
                    SignalTag(decision: alerte.apres),
                  ],
                )
              else
                Text(
                  '${Format.nombre(alerte.montant)} FCFA par action · acheter au plus tard le '
                  '${Format.dateCourte(alerte.dateButoir)}',
                  style: AppTypo.style(taille: 13, couleur: c.texteMoyen),
                ),
              const SizedBox(height: 4),
              Text(
                'Séance du ${Format.date(alerte.date)}${alerte.detenu ? ' · dans votre portefeuille' : ''}',
                style: AppTypo.style(taille: 12, couleur: c.texteFaible),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cloche de l'écran Marché, avec le nombre d'alertes non lues.
class BoutonAlertes extends StatelessWidget {
  const BoutonAlertes({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        final nonLues = state is AlertsLoaded ? state.alertes.nonLues : 0;
        return IconButton(
          onPressed: () => ouvrirAlertes(context),
          tooltip: nonLues == 0 ? 'Alertes' : 'Alertes, $nonLues non lues',
          icon: Badge(
            isLabelVisible: nonLues > 0,
            label: Text(nonLues > 99 ? '99+' : '$nonLues'),
            backgroundColor: c.baisse,
            child: Icon(nonLues > 0 ? Icons.notifications : Icons.notifications_none, color: c.texte, size: 26),
          ),
        );
      },
    );
  }
}
