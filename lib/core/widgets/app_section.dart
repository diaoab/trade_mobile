import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

/// Bloc titré d'un écran : titre discret en capitales, action à droite, et
/// contenu posé sur une carte arrondie ([carte] faux : directement sur le fond).
class AppSection extends StatelessWidget {
  final String? titre;
  final Widget? action;
  final List<Widget> enfants;
  final bool carte;

  const AppSection({super.key, this.titre, this.action, required this.enfants, this.carte = true});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Padding(
      padding: const EdgeInsets.only(top: AppEspace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titre != null || action != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 0, AppEspace.gouttiere, 8),
              child: Row(
                children: [
                  if (titre != null)
                    Expanded(
                      child: Text(titre!.toUpperCase(),
                          style: AppTypo.style(taille: 12, graisse: FontWeight.w700, couleur: c.texteMoyen, interlettre: 0.8)),
                    ),
                  ?action,
                ],
              ),
            ),
          if (carte)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppEspace.carte),
              padding: const EdgeInsets.symmetric(vertical: AppEspace.m),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRayon.carte),
                border: Border.all(color: c.separateur.withValues(alpha: 0.6), width: 0.6),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: enfants),
            )
          else
            ...enfants,
        ],
      ),
    );
  }
}

/// Filet de séparation, décalé de la gouttière comme les listes iOS.
class AppFilet extends StatelessWidget {
  final double retrait;
  const AppFilet({super.key, this.retrait = AppEspace.gouttiere});

  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, margin: EdgeInsets.only(left: retrait), color: context.couleurs.separateur);
}

/// Ligne de liste : contenu en rangée, appui facultatif, filet dessous.
class AppLigne extends StatelessWidget {
  final List<Widget> enfants;
  final VoidCallback? onTap;
  final bool derniere;

  const AppLigne({super.key, required this.enfants, this.onTap, this.derniere = false});

  @override
  Widget build(BuildContext context) {
    final contenu = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: 14),
      child: Row(children: _espaces(enfants)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onTap == null)
          contenu
        else
          InkWell(onTap: onTap, highlightColor: context.couleurs.champ, splashColor: Colors.transparent, child: contenu),
        if (!derniere) const AppFilet(),
      ],
    );
  }

  static List<Widget> _espaces(List<Widget> enfants) => [
        for (var i = 0; i < enfants.length; i++) ...[if (i > 0) const SizedBox(width: AppEspace.m), enfants[i]],
      ];
}
