import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_section.dart';
import '../../domain/entities/analysis.dart';

/// Une ligne par indicateur : nom, explication courte, sens du signal.
class IndicatorRow extends StatelessWidget {
  final DetailIndicateur detail;
  final bool derniere;

  const IndicatorRow({super.key, required this.detail, required this.derniere});

  // La volatilité mesure un risque, pas un sens : libellés et icônes propres.
  static const _libelles = {
    Ton.positif: 'Haussier',
    Ton.negatif: 'Baissier',
    Ton.neutre: 'Neutre',
  };
  static const _libellesVolatilite = {
    Ton.positif: 'Faible',
    Ton.negatif: 'Élevée',
    Ton.neutre: 'Modérée',
  };
  static const _icones = {
    Ton.positif: Icons.arrow_upward,
    Ton.negatif: Icons.arrow_downward,
    Ton.neutre: Icons.remove,
  };
  static const _iconesVolatilite = {
    Ton.positif: Icons.verified_user_outlined,
    Ton.negatif: Icons.warning_amber_outlined,
    Ton.neutre: Icons.remove,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final volatilite = detail.indicateur == 'Volatilité';
    final couleur = switch (detail.ton) {
      Ton.positif => c.hausse,
      Ton.negatif => c.baisse,
      Ton.neutre => c.texteMoyen,
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.indicateur, style: AppTypo.style(taille: 16, graisse: FontWeight.w600, couleur: c.texte)),
                    const SizedBox(height: 3),
                    Text(detail.texte, style: AppTypo.style(taille: 14, couleur: c.texteMoyen, hauteur: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: AppEspace.l),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon((volatilite ? _iconesVolatilite : _icones)[detail.ton], size: 14, color: couleur),
                    const SizedBox(width: 3),
                    Text((volatilite ? _libellesVolatilite : _libelles)[detail.ton]!,
                        style: AppTypo.style(taille: 14, graisse: FontWeight.w600, couleur: couleur)),
                  ]),
                  if (!detail.compte) ...[
                    const SizedBox(height: 3),
                    Text('hors score', style: AppTypo.style(taille: 12, couleur: c.texteFaible)),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!derniere) const AppFilet(),
      ],
    );
  }
}
