import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

class Chargement extends StatelessWidget {
  const Chargement({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
}

/// Message d'erreur en rouge, sous la gouttière ; rien si [message] est vide.
class MessageErreur extends StatelessWidget {
  final String? message;
  const MessageErreur(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: AppEspace.s),
      child: Text(message!, style: AppTypo.style(taille: 15, couleur: context.couleurs.baisse, hauteur: 1.35)),
    );
  }
}

/// Texte secondaire.
class TexteDiscret extends StatelessWidget {
  final String texte;
  final TextAlign? alignement;
  final Color? couleur;
  const TexteDiscret(this.texte, {super.key, this.alignement, this.couleur});

  @override
  Widget build(BuildContext context) => Text(texte,
      textAlign: alignement,
      style: AppTypo.style(taille: 15, couleur: couleur ?? context.couleurs.texteMoyen, hauteur: 1.4));
}

/// Note de bas d'écran (avertissement, méthode de calcul).
class NotePied extends StatelessWidget {
  final String texte;
  const NotePied(this.texte, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xxl, AppEspace.gouttiere, 0),
        child: Text(texte, style: AppTypo.style(taille: 12, couleur: context.couleurs.texteFaible, hauteur: 1.45)),
      );
}

/// État vide d'une liste : icône, titre, explication.
class EtatVide extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String texte;
  const EtatVide({super.key, required this.icone, required this.titre, required this.texte});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          Icon(icone, size: 36, color: c.texteFaible),
          const SizedBox(height: AppEspace.s),
          Text(titre, style: AppTypo.style(taille: 20, graisse: FontWeight.w600, couleur: c.texte)),
          const SizedBox(height: AppEspace.s),
          TexteDiscret(texte, alignement: TextAlign.center),
        ],
      ),
    );
  }
}
