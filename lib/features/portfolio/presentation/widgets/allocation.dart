import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/portfolio.dart';

/// Répartition par titre : nuances neutres, la couleur restant réservée aux
/// gains et pertes.
class Allocation extends StatelessWidget {
  final Portfolio portfolio;
  const Allocation({super.key, required this.portfolio});

  static const _clair = [Color(0xFF1C1B17), Color(0xFF5E594C), Color(0xFF8F8878), Color(0xFFB8AF9A), Color(0xFF2F5FB3), Color(0xFFB06D0E)];
  static const _sombre = [Color(0xFFF5F5F4), Color(0xFFB5B4B0), Color(0xFF7D7C78), Color(0xFF4C4B48), Color(0xFF5B8DEF), Color(0xFFE09A3A)];

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final nuances = Theme.of(context).brightness == Brightness.dark ? _sombre : _clair;
    final total = portfolio.totaux.valeur == 0 ? 1 : portfolio.totaux.valeur;
    final parts = [
      for (final (i, p) in portfolio.positions.where((p) => p.valorisation != null).indexed)
        (p.nom, p.valorisation!.valeur / total, nuances[i % nuances.length]),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 20, AppEspace.gouttiere, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(children: [
                for (final (_, part, couleur) in parts)
                  Expanded(
                    flex: (part * 1000).round().clamp(1, 1000),
                    child: Container(margin: const EdgeInsets.only(right: 2), color: couleur),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final (nom, part, couleur) in parts)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 6),
                  Text('$nom ${Format.nombre(part * 100)} %',
                      style: AppTypo.style(taille: 13, couleur: c.texteMoyen, tabulaire: true)),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
