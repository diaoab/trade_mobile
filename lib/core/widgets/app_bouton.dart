import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

/// Bouton principal (encre pleine) ou secondaire (surface).
class AppBouton extends StatelessWidget {
  final String libelle;

  /// `null` désactive le bouton.
  final VoidCallback? onPressed;
  final bool enChargement;
  final bool secondaire;

  const AppBouton({
    super.key,
    required this.libelle,
    this.onPressed,
    this.enChargement = false,
    this.secondaire = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final texte = secondaire ? c.texte : c.surEncre;
    final actif = onPressed != null && !enChargement;
    return Opacity(
      opacity: onPressed == null ? 0.35 : 1,
      child: SizedBox(
        height: 52,
        child: TextButton(
          onPressed: actif ? onPressed : null,
          style: TextButton.styleFrom(
            backgroundColor: secondaire ? c.champ : c.encre,
            disabledBackgroundColor: secondaire ? c.champ : c.encre,
            foregroundColor: texte,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRayon.l),
              side: secondaire ? BorderSide(color: c.separateur) : BorderSide.none,
            ),
          ),
          child: enChargement
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: texte))
              : Text(libelle, style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: texte)),
        ),
      ),
    );
  }
}

/// Lien texte (« Modifier », « Annuler »…).
class AppLien extends StatelessWidget {
  final String libelle;
  final VoidCallback? onPressed;
  final Color? couleur;

  const AppLien({super.key, required this.libelle, this.onPressed, this.couleur});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(libelle,
              style: AppTypo.style(taille: 16, graisse: FontWeight.w600, couleur: couleur ?? context.couleurs.encre)),
        ),
      );
}
