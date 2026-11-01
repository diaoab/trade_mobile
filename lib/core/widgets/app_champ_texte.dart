import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

/// Champ de saisie avec son libellé au-dessus.
class AppChampTexte extends StatelessWidget {
  final String libelle;
  final TextEditingController controller;
  final String? indication;
  final bool motDePasse;
  final TextInputType? clavier;
  final Iterable<String>? autofill;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const AppChampTexte({
    super.key,
    required this.libelle,
    required this.controller,
    this.indication,
    this.motDePasse = false,
    this.clavier,
    this.autofill,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(libelle, style: AppTypo.style(taille: 13, graisse: FontWeight.w500, couleur: c.texteMoyen)),
        const SizedBox(height: AppEspace.s),
        TextField(
          controller: controller,
          obscureText: motDePasse,
          keyboardType: clavier,
          autofillHints: autofill,
          autocorrect: !motDePasse && clavier != TextInputType.emailAddress,
          enableSuggestions: !motDePasse,
          textCapitalization: TextCapitalization.none,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppTypo.style(taille: 17, couleur: c.texte),
          decoration: InputDecoration(
            hintText: indication,
            hintStyle: AppTypo.style(taille: 17, couleur: c.texteFaible),
            filled: true,
            fillColor: c.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRayon.m), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
