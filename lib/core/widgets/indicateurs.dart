import 'package:flutter/material.dart';

import '../constants/signaux.dart';
import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';
import '../utils/format.dart';

/// Signal du moteur : point de couleur et libellé, sans pastille.
class SignalTag extends StatelessWidget {
  final String? decision;
  final bool grand;

  const SignalTag({super.key, required this.decision, this.grand = false});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final signal = Signal.depuis(decision);
    final couleur = signal?.couleur(c) ?? c.texteFaible;
    final taillePoint = grand ? 10.0 : 7.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: taillePoint, height: taillePoint, decoration: BoxDecoration(color: couleur, shape: BoxShape.circle)),
        SizedBox(width: grand ? 8 : 6),
        Text(signal?.libelle ?? decision ?? 'Sans signal',
            style: AppTypo.style(taille: grand ? 20 : 13, graisse: FontWeight.w600, couleur: couleur)),
      ],
    );
  }
}

/// Variation en pastille pleine, comme dans l'app Bourse d'iOS.
class ChangePill extends StatelessWidget {
  final num? valeur;
  const ChangePill({super.key, required this.valeur});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final v = valeur;
    final fond = v == null || v == 0 ? c.surface : (v > 0 ? c.hausse : c.baisse);
    return Container(
      constraints: const BoxConstraints(minWidth: 76),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(6)),
      child: Text(Format.pourcentage(v),
          textAlign: TextAlign.right,
          style: AppTypo.style(
              taille: 14, graisse: FontWeight.w600, couleur: v == null || v == 0 ? c.texteMoyen : Colors.white, tabulaire: true)),
    );
  }
}

class ElementStat {
  final String libelle;
  final String valeur;
  final Color? couleur;
  const ElementStat(this.libelle, this.valeur, {this.couleur});
}

/// Grille de chiffres clés, deux colonnes séparées par des filets.
class GrilleStats extends StatelessWidget {
  final List<ElementStat> elements;
  const GrilleStats({super.key, required this.elements});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final lignes = <Widget>[];
    for (var i = 0; i < elements.length; i += 2) {
      final derniere = i + 2 >= elements.length;
      lignes.add(Container(
        decoration: BoxDecoration(border: derniere ? null : Border(bottom: BorderSide(color: c.separateur, width: 0.5))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _cellule(context, elements[i], gauche: true)),
              Container(width: 0.5, color: c.separateur),
              Expanded(child: i + 1 < elements.length ? _cellule(context, elements[i + 1]) : const SizedBox()),
            ],
          ),
        ),
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
      child: Column(children: lignes),
    );
  }

  Widget _cellule(BuildContext context, ElementStat e, {bool gauche = false}) {
    final c = context.couleurs;
    return Padding(
      padding: EdgeInsets.only(left: gauche ? 0 : AppEspace.l, top: AppEspace.m, bottom: AppEspace.m, right: AppEspace.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.libelle, style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
          const SizedBox(height: 3),
          Text(e.valeur,
              style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: e.couleur ?? c.texte, tabulaire: true)),
        ],
      ),
    );
  }
}

/// Choix exclusif compact (périodes du graphique…).
class Segmente<T> extends StatelessWidget {
  final List<T> options;
  final T valeur;
  final ValueChanged<T> onChanged;
  final String Function(T) libelle;

  const Segmente({super.key, required this.options, required this.valeur, required this.onChanged, required this.libelle});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.s + 1)),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: option == valeur ? c.fond : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRayon.s - 1),
                  ),
                  child: Text(libelle(option),
                      style: AppTypo.style(
                          taille: 13,
                          graisse: option == valeur ? FontWeight.w600 : FontWeight.w500,
                          couleur: option == valeur ? c.texte : c.texteMoyen)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
