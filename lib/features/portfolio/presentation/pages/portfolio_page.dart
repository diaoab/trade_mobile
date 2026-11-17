import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/bandeau_cours_anciens.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/portfolio.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import '../bloc/portfolio_state.dart';
import '../widgets/add_position_sheet.dart';
import '../widgets/allocation.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _edition = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        final bloc = context.read<PortfolioBloc>();
        final portfolio = state is PortfolioLoaded ? state.portfolio : null;
        final aDesPositions = portfolio != null && portfolio.positions.isNotEmpty;
        return AppEcran(
          titre: 'Portefeuille',
          action: aDesPositions
              ? AppLien(libelle: _edition ? 'OK' : 'Modifier', onPressed: () => setState(() => _edition = !_edition))
              : null,
          onActualiser: () async {
            bloc.add(LoadPortfolio());
            await bloc.stream.firstWhere((s) => s is! PortfolioLoading);
          },
          enfants: [
            if (state is PortfolioError) MessageErreur(state.message),
            if (state is PortfolioLoading || state is PortfolioInitial) const Chargement(),
            if (state is PortfolioLoaded && _edition) MessageErreur(state.erreurAction),
            if (portfolio != null && aDesPositions) ...[
              BandeauCoursAnciens(date: portfolio.totaux.dateCours, portee: 'La valorisation et le résultat'),
              if (portfolio.positions.any((p) => p.valorisation != null)) ..._synthese(context, portfolio),
              _NoteAttenteCours(portfolio: portfolio),
            ],
            if (portfolio != null && !aDesPositions)
              const EtatVide(
                icone: Icons.pie_chart_outline,
                titre: 'Aucune position',
                texte: 'Ajoutez les titres que vous détenez pour suivre leur valeur, vos dividendes et le résultat net de frais.',
              ),
            if (aDesPositions)
              AppSection(
                titre: 'Positions',
                enfants: [
                  for (var i = 0; i < portfolio.positions.length; i++)
                    _LignePosition(
                      position: portfolio.positions[i],
                      derniere: i == portfolio.positions.length - 1,
                      edition: _edition,
                    ),
                ],
              ),
            if (portfolio != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xl, AppEspace.gouttiere, 0),
                child: AppBouton(
                  libelle: 'Ajouter une position',
                  secondaire: aDesPositions,
                  onPressed: () => ouvrirAjoutPosition(context),
                ),
              ),
            if (aDesPositions)
              const NotePied('Valorisation au dernier cours coté. Résultat net = plus-value latente + dividendes perçus − '
                  'frais estimés d’un aller-retour.'),
          ],
        );
      },
    );
  }

  List<Widget> _synthese(BuildContext context, Portfolio p) {
    final c = context.couleurs;
    final t = p.totaux;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.s, AppEspace.gouttiere, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: Format.nombre(t.valeur)),
                TextSpan(text: ' FCFA', style: AppTypo.style(taille: 17, graisse: FontWeight.w500, couleur: c.texteMoyen)),
              ]),
              style: AppTypo.style(taille: 34, graisse: FontWeight.w600, couleur: c.texte, interlettre: -0.8, tabulaire: true),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: '${Format.signe(t.net)} FCFA (${Format.pourcentage(t.netPct)})'),
                TextSpan(text: '  résultat net', style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
              ]),
              style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.variation(t.net), tabulaire: true),
            ),
            if (t.dateCours != null) ...[
              const SizedBox(height: 4),
              Text('Valorisé au cours du ${Format.date(t.dateCours)}',
                  style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
            ],
          ],
        ),
      ),
      Allocation(portfolio: p),
      const SizedBox(height: AppEspace.xl),
      GrilleStats(elements: [
        ElementStat('Investi', Format.nombre(t.cout)),
        ElementStat('Dividendes perçus', Format.nombre(t.dividendes)),
        ElementStat('Frais estimés', Format.nombre(t.frais)),
        ElementStat('Plus-value latente', Format.signe(t.plusValueLatente), couleur: c.variation(t.plusValueLatente)),
      ]),
    ];
  }
}

class _LignePosition extends StatelessWidget {
  final Position position;
  final bool derniere;
  final bool edition;

  const _LignePosition({required this.position, required this.derniere, required this.edition});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final v = position.valorisation;
    return AppLigne(
      derniere: derniere,
      onTap: edition ? null : () => Navigator.of(context).pushNamed(AppRouter.analyseRoute, arguments: position.symbol),
      enfants: [
        if (edition)
          IconButton(
            onPressed: () => context.read<PortfolioBloc>().add(PositionDeleted(position.id)),
            icon: Icon(Icons.remove_circle, color: c.baisse),
            tooltip: 'Supprimer ${position.nom}',
            visualDensity: VisualDensity.compact,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(position.nom, style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte)),
              const SizedBox(height: 3),
              Text(
                '${Format.nombre(position.quantite)} titres · PRU ${Format.nombre(position.prixAchat)} · '
                '${Format.dateCourte(position.dateAchat)}',
                style: AppTypo.style(taille: 13, couleur: c.texteMoyen, tabulaire: true),
              ),
            ],
          ),
        ),
        if (v != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Format.nombre(v.valeur), style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true)),
              const SizedBox(height: 4),
              ChangePill(valeur: v.netPct),
            ],
          )
        else if (position.enAttenteCours)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Format.nombre(position.quantite * position.prixAchat),
                  style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true)),
              const SizedBox(height: 4),
              Text('En attente de cours', style: AppTypo.style(taille: 13, graisse: FontWeight.w500, couleur: c.prudence)),
            ],
          ),
      ],
    );
  }
}

/// Explique pourquoi des positions ne sont pas valorisées : elles ont été
/// achetées après la dernière séance connue de l'app.
class _NoteAttenteCours extends StatelessWidget {
  final Portfolio portfolio;
  const _NoteAttenteCours({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final enAttente = portfolio.positions.where((p) => p.enAttenteCours).toList();
    if (enAttente.isEmpty) return const SizedBox.shrink();
    final dateCours = enAttente.first.dateCours;
    final texte = enAttente.length == 1
        ? '${enAttente.first.nom} a été acheté après la dernière séance connue (${Format.date(dateCours)}). '
            'Sa valeur et son résultat s’afficheront dès que les cours seront mis à jour ; '
            'il n’est pas compté dans le total.'
        : '${enAttente.length} positions ont été achetées après la dernière séance connue '
            '(${Format.date(dateCours)}). Leur valeur et leur résultat s’afficheront dès que les cours '
            'seront mis à jour ; elles ne sont pas comptées dans le total.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.m, AppEspace.gouttiere, 0),
      child: TexteDiscret(texte),
    );
  }
}
