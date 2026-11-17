import 'package:flutter/material.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../onboarding/presentation/pages/prise_en_main_page.dart';
import 'connexion_requise.dart';

/// Onglet Compte d'un visiteur en démo : ce qu'apporte un compte, et l'aide.
class CompteInvite extends StatelessWidget {
  const CompteInvite({super.key});

  static const _avantages = [
    (Icons.star_outline_rounded, 'Favoris', 'Vos titres en tête du marché'),
    (Icons.notifications_none, 'Alertes', 'Prévenu quand un signal change ou qu’un dividende approche'),
    (Icons.pie_chart_outline, 'Portefeuille', 'Valeur, dividendes et résultat net de frais'),
    (Icons.chat_bubble_outline, 'Assistant', 'Vos questions sur une analyse'),
    (Icons.tune, 'Réglages', 'Indicateurs et frais à votre mesure'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return AppEcran(
      titre: 'Compte',
      sousTitre: 'Mode démo',
      enfants: [
        const ConnexionRequise(
          icone: Icons.person_outline,
          titre: 'Un compte, c’est gratuit',
          raison: 'garder vos favoris, votre portefeuille et vos alertes',
        ),
        AppSection(
          titre: 'Ce que vous débloquez',
          enfants: [
            for (var i = 0; i < _avantages.length; i++)
              AppLigne(
                derniere: i == _avantages.length - 1,
                enfants: [
                  Icon(_avantages[i].$1, size: 22, color: c.texte),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_avantages[i].$2, style: AppTypo.style(taille: 16, graisse: FontWeight.w600, couleur: c.texte)),
                        const SizedBox(height: 2),
                        Text(_avantages[i].$3, style: AppTypo.style(taille: 13, couleur: c.texteMoyen)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        AppSection(
          titre: 'Aide',
          enfants: [
            AppLigne(
              derniere: true,
              onTap: () => ouvrirPriseEnMain(context),
              enfants: [
                Expanded(child: Text('Comment lire les signaux', style: AppTypo.style(taille: 16, couleur: c.texte))),
                Icon(Icons.chevron_right, size: 20, color: c.texteFaible),
              ],
            ),
          ],
        ),
        const NotePied(kAvertissement),
      ],
    );
  }
}
