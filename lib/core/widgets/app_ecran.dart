import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

/// Écran défilant avec un grand titre (style iOS) quand [titre] est fourni,
/// et tirer-pour-actualiser quand [onActualiser] l'est.
class AppEcran extends StatelessWidget {
  final String? titre;
  final String? sousTitre;
  final Widget? action;
  final List<Widget> enfants;
  final Future<void> Function()? onActualiser;

  const AppEcran({
    super.key,
    this.titre,
    this.sousTitre,
    this.action,
    required this.enfants,
    this.onActualiser,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final liste = ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppEspace.m, bottom: 48),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kLargeurMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (titre != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 0, AppEspace.gouttiere, AppEspace.s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(titre!,
                                  style: AppTypo.style(taille: 34, graisse: FontWeight.w700, couleur: c.texte, interlettre: -0.6)),
                              if (sousTitre != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(sousTitre!, style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
                                ),
                            ],
                          ),
                        ),
                        ?action,
                      ],
                    ),
                  ),
                ...enfants,
              ],
            ),
          ),
        ),
      ],
    );
    return SafeArea(
      bottom: false,
      child: onActualiser == null
          ? liste
          : RefreshIndicator(onRefresh: onActualiser!, color: c.texteMoyen, backgroundColor: c.surface, child: liste),
    );
  }
}
