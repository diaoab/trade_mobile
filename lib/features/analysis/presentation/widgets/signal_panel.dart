import 'package:flutter/material.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/analysis.dart';

/// Bloc du signal : décision, score, jauge 0-100 remplie jusqu'au score avec
/// les seuils du moteur marqués, et les trois sous-scores.
class SignalPanel extends StatelessWidget {
  final ResultatDecision resultat;
  const SignalPanel({super.key, required this.resultat});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final signal = Signal.depuis(resultat.decision);
    final couleur = signal?.couleur(c) ?? c.texteFaible;
    final score = resultat.score.clamp(0, 100) / 100;
    const zones = [
      (Signal.vente, kSeuilConserver / 2),
      (Signal.conserver, (kSeuilConserver + kSeuilAchat) / 2),
      (Signal.achat, (kSeuilAchat + 100) / 2),
    ];
    final mesures = [
      ('Confiance', '${Format.nombre(resultat.confiance)} %'),
      ('Technique', Format.nombre(resultat.scoreTechnique)),
      ('Risque', Format.nombre(resultat.scoreRisque)),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SIGNAL DU MOTEUR',
                        style: AppTypo.style(taille: 12, graisse: FontWeight.w600, couleur: c.texteMoyen, interlettre: 0.4)),
                    const SizedBox(height: 2),
                    Text(signal?.libelle ?? '—',
                        style: AppTypo.style(taille: 28, graisse: FontWeight.w700, couleur: couleur, interlettre: -0.5)),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: Format.nombre(resultat.score)),
                  TextSpan(text: '/100', style: AppTypo.style(taille: 15, graisse: FontWeight.w500, couleur: c.texteMoyen)),
                ]),
                style: AppTypo.style(taille: 28, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, contraintes) {
            final largeur = contraintes.maxWidth;
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                        Container(color: c.separateur),
                        FractionallySizedBox(
                          widthFactor: score.toDouble(),
                          child: Container(decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(4))),
                        ),
                        for (final seuil in [kSeuilConserver, kSeuilAchat])
                          Positioned(left: largeur * seuil / 100 - 1.5, top: 0, bottom: 0, child: Container(width: 3, color: c.surface)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 26,
                  child: Stack(
                    children: [
                      for (final (zone, centre) in zones)
                        Positioned(
                          left: largeur * centre / 100 - 45,
                          width: 90,
                          top: 8,
                          child: Text(zone.libelle,
                              textAlign: TextAlign.center,
                              style: AppTypo.style(
                                  taille: 12,
                                  graisse: zone == signal ? FontWeight.w600 : FontWeight.w400,
                                  couleur: zone == signal ? couleur : c.texteFaible)),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
          if (resultat.scoreSeance != null)
            Padding(
              padding: const EdgeInsets.only(top: AppEspace.s),
              child: Text(_explicationLissage(resultat), style: AppTypo.style(taille: 13, couleur: c.texteMoyen, hauteur: 1.4)),
            ),
          Container(
            margin: const EdgeInsets.only(top: AppEspace.l),
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.separateur, width: 0.5))),
            child: Row(
              children: [
                for (final (libelle, valeur) in mesures)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(libelle, style: AppTypo.style(taille: 12, couleur: c.texteMoyen)),
                        const SizedBox(height: 2),
                        Text(valeur, style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Le signal repose sur le score lissé : un écart d'une seule séance ne le
/// fait pas basculer. Explique l'écart avec le score brut du jour.
String _explicationLissage(ResultatDecision r) {
  final duJour = Format.nombre(r.scoreSeance);
  final signalDuJour = Signal.depuis(r.decisionSeance);
  final base = 'Score lissé sur les dernières séances (séance du jour : $duJour/100).';
  if (signalDuJour == null || r.decisionSeance == r.decision) return base;
  return '$base À elle seule, la séance indiquerait « ${signalDuJour.libelle} » : '
      'le signal attend que la tendance se confirme avant de changer.';
}
