import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/analysis.dart';
import '../../domain/entities/simulation_achat.dart';

/// « Et si j'investissais… » : combien d'actions, combien de frais, quel
/// dividende et quel résultat selon l'évolution du cours.
class SimulateurSection extends StatefulWidget {
  final Analysis analyse;
  const SimulateurSection({super.key, required this.analyse});

  /// Frais par défaut si le compte n'en renvoie pas (même valeur que l'API).
  static const double fraisParDefaut = 2;

  @override
  State<SimulateurSection> createState() => _SimulateurSectionState();
}

class _SimulateurSectionState extends State<SimulateurSection> {
  final _budget = TextEditingController(text: '500 000');

  static const _variations = [-10.0, 0.0, 10.0];

  @override
  void dispose() {
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final a = widget.analyse;
    final budget = Format.lireNombre(_budget.text) ?? 0;
    final sim = SimulationAchat(
      budget: budget,
      cours: a.cours,
      fraisAllerRetour: a.fraisAllerRetour ?? SimulateurSection.fraisParDefaut,
      dividendeParAction: a.dividende?.montant,
    );
    final assez = sim.quantite > 0;

    return AppSection(
      titre: 'Simuler un achat',
      enfants: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
          child: TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9  ]'))],
            onChanged: (_) => setState(() {}),
            style: AppTypo.style(taille: 22, graisse: FontWeight.w600, couleur: c.texte, tabulaire: true),
            decoration: InputDecoration(
              labelText: 'Montant à investir',
              suffixText: 'FCFA',
              filled: true,
              fillColor: c.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: AppEspace.m),
        if (!assez)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
            child: TexteDiscret('Il faut au moins ${Format.nombre(sim.cours * (1 + sim.fraisAllerRetour / 200))} FCFA '
                'pour acheter une action ${a.nom}, frais compris.'),
          )
        else ...[
          GrilleStats(elements: [
            ElementStat('Actions achetées', Format.nombre(sim.quantite)),
            ElementStat('Frais d’achat', '${Format.nombre(sim.fraisAchat)} FCFA'),
            ElementStat('Total déboursé', '${Format.nombre(sim.totalDebourse)} FCFA'),
            ElementStat('Reste non investi', '${Format.nombre(sim.reste)} FCFA'),
            if (sim.dividende != null) ElementStat('Prochain dividende', '${Format.nombre(sim.dividende)} FCFA'),
            ElementStat('Rentable au-dessus de', '${Format.nombre(sim.coursEquilibre)} FCFA'),
          ]),
          const SizedBox(height: AppEspace.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
            child: Text('Résultat net à la revente, frais de vente compris',
                style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
          ),
          for (var i = 0; i < _variations.length; i++)
            AppLigne(
              derniere: i == _variations.length - 1,
              enfants: [
                Expanded(
                  child: Text(
                    _variations[i] == 0 ? 'Cours inchangé' : 'Cours ${Format.pourcentage(_variations[i], decimales: 0)}',
                    style: AppTypo.style(taille: 16, couleur: c.texte),
                  ),
                ),
                Text('${Format.signe(sim.resultatSi(_variations[i]))} FCFA',
                    style: AppTypo.style(
                        taille: 16, graisse: FontWeight.w600, couleur: c.variation(sim.resultatSi(_variations[i])), tabulaire: true)),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.s, AppEspace.gouttiere, 0),
            child: TexteDiscret(
              'Au cours de ${Format.nombre(sim.cours)} FCFA (séance du ${Format.date(a.seance)}), avec '
              '${Format.nombre(sim.fraisAllerRetour, decimales: 1)} % de frais pour un aller-retour '
              '(modifiable dans Compte). Le cours doit monter d’au moins '
              '${Format.pourcentage(sim.hausseEquilibre, decimales: 1)} pour couvrir les frais.',
            ),
          ),
        ],
      ],
    );
  }
}
