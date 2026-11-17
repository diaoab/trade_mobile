import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';

/// Champ de saisie avec son libellé au-dessus. Un champ [motDePasse] a un
/// œil pour afficher ou masquer ce qui est tapé.
class AppChampTexte extends StatefulWidget {
  final String libelle;
  final TextEditingController controller;
  final String? indication;
  final bool motDePasse;
  final TextInputType? clavier;
  final Iterable<String>? autofill;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// Icône à gauche du champ (enveloppe, cadenas…).
  final IconData? icone;

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
    this.icone,
  });

  @override
  State<AppChampTexte> createState() => _AppChampTexteState();
}

class _AppChampTexteState extends State<AppChampTexte> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final motDePasse = widget.motDePasse;
    final masque = motDePasse && !_visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.libelle, style: AppTypo.style(taille: 13, graisse: FontWeight.w500, couleur: c.texteMoyen)),
        const SizedBox(height: AppEspace.s),
        TextField(
          controller: widget.controller,
          obscureText: masque,
          keyboardType: widget.clavier,
          autofillHints: widget.autofill,
          autocorrect: !motDePasse && widget.clavier != TextInputType.emailAddress,
          enableSuggestions: !motDePasse,
          textCapitalization: TextCapitalization.none,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          style: AppTypo.style(taille: 17, couleur: c.texte),
          decoration: InputDecoration(
            hintText: widget.indication,
            hintStyle: AppTypo.style(taille: 17, couleur: c.texteFaible),
            filled: true,
            fillColor: c.champ,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRayon.l),
              borderSide: BorderSide(color: c.separateur),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRayon.l),
              borderSide: BorderSide(color: c.encre, width: 1.5),
            ),
            prefixIcon: widget.icone == null ? null : Icon(widget.icone, size: 20, color: c.texteMoyen),
            suffixIcon: motDePasse
                ? IconButton(
                    onPressed: () => setState(() => _visible = !_visible),
                    tooltip: _visible ? 'Masquer le mot de passe' : 'Afficher le mot de passe',
                    icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: c.texteMoyen),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRayon.l), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
