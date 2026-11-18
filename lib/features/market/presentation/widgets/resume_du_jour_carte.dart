import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/fraicheur.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/resume_du_jour.dart';

/// Section « Aujourd'hui » : portefeuille sur la séance, signaux qui ont
/// basculé, dividendes dont la date butoir approche.
class ResumeDuJourCarte extends StatelessWidget {
  final ResumeDuJour resume;

  /// Séance du résumé : « Aujourd'hui » n'est écrit que si elle est récente.
  final String? seance;
  const ResumeDuJourCarte({super.key, required this.resume, this.seance});

  @override
  Widget build(BuildContext context) {
    final lignes = <Widget>[
      if (resume.portefeuille != null) _LignePortefeuille(seance: resume.portefeuille!),
      if (resume.bascules.isEmpty)
        const _LigneTexte(
          icone: Icons.check_circle_outline,
          texte: 'Aucun signal n’a changé depuis la séance précédente.',
        ),
      for (final b in resume.bascules) _LigneBascule(bascule: b),
      for (final d in resume.dividendes) _LigneDividende(dividende: d),
    ];
    return AppSection(
      titre: Fraicheur.estAncienne(seance) ? 'Dernière séance' : 'Aujourd’hui',
      enfants: [
        for (var i = 0; i < lignes.length; i++)
          i == lignes.length - 1 ? lignes[i] : _AvecSeparateur(enfant: lignes[i]),
      ],
    );
  }
}

class _AvecSeparateur extends StatelessWidget {
  final Widget enfant;
  const _AvecSeparateur({required this.enfant});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          enfant,
          Padding(
            padding: const EdgeInsets.only(left: AppEspace.gouttiere),
            child: Divider(height: 0.5, thickness: 0.5, color: context.couleurs.separateur),
          ),
        ],
      );
}

class _Ligne extends StatelessWidget {
  final IconData icone;
  final Color? couleurIcone;
  final Widget contenu;
  final Widget? fin;
  final VoidCallback? onTap;

  const _Ligne({required this.icone, required this.contenu, this.couleurIcone, this.fin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: AppEspace.m),
        child: Row(
          children: [
            Icon(icone, size: 20, color: couleurIcone ?? c.texteMoyen),
            const SizedBox(width: AppEspace.m),
            Expanded(child: contenu),
            if (fin != null) ...[const SizedBox(width: AppEspace.s), fin!],
            if (onTap != null) ...[
              const SizedBox(width: AppEspace.xs),
              Icon(Icons.chevron_right, size: 18, color: c.texteFaible),
            ],
          ],
        ),
      ),
    );
  }
}

class _LigneTexte extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _LigneTexte({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) => _Ligne(
        icone: icone,
        contenu: Text(texte, style: AppTypo.style(taille: 15, couleur: context.couleurs.texteMoyen, hauteur: 1.35)),
      );
}

class _LignePortefeuille extends StatelessWidget {
  final SeancePortefeuille seance;
  const _LignePortefeuille({required this.seance});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return _Ligne(
      icone: Icons.pie_chart_outline,
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Votre portefeuille', style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.texte)),
          const SizedBox(height: 2),
          Text('sur la dernière séance', style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
        ],
      ),
      fin: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${Format.signe(seance.montant)} FCFA',
              style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.variation(seance.montant), tabulaire: true)),
          const SizedBox(height: 2),
          Text(Format.pourcentage(seance.pourcentage),
              style: AppTypo.style(taille: 13, couleur: c.variation(seance.montant), tabulaire: true)),
        ],
      ),
    );
  }
}

class _LigneBascule extends StatelessWidget {
  final BasculeSignal bascule;
  const _LigneBascule({required this.bascule});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final apres = bascule.apres;
    final (icone, couleur, titre) = switch (apres) {
      'ACHETER' => (Icons.trending_up_rounded, c.hausse, 'Moment d’acheter ${bascule.nom}'),
      'VENDRE' => (Icons.trending_down_rounded, c.baisse, 'Moment de vendre ${bascule.nom}'),
      _ => (Icons.swap_vert, c.texte, '${bascule.nom} passe à « Conserver »'),
    };
    return _Ligne(
      icone: icone,
      couleurIcone: couleur,
      onTap: () => Navigator.of(context).pushNamed(AppRouter.analyseRoute, arguments: bascule.symbol),
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.texte)),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              SignalTag(decision: bascule.avant),
              Icon(Icons.arrow_forward, size: 14, color: c.texteMoyen),
              SignalTag(decision: bascule.apres),
            ],
          ),
        ],
      ),
    );
  }
}

class _LigneDividende extends StatelessWidget {
  final DividendeProche dividende;
  const _LigneDividende({required this.dividende});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final quand = switch (dividende.joursRestants) {
      0 => 'aujourd’hui',
      1 => 'demain',
      _ => 'avant le ${Format.dateCourte(dividende.dateButoir)} (J−${dividende.joursRestants})',
    };
    return _Ligne(
      icone: Icons.event_outlined,
      couleurIcone: c.prudence,
      onTap: () => Navigator.of(context).pushNamed(AppRouter.analyseRoute, arguments: dividende.symbol),
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dividende ${dividende.nom} : ${Format.nombre(dividende.montant)} FCFA par action',
              style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.texte)),
          const SizedBox(height: 2),
          Text('Acheter $quand pour y avoir droit', style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
        ],
      ),
    );
  }
}
