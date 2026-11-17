import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Visiteur sans compte (mode démo).
bool estInvite(BuildContext context) => context.read<AuthBloc>().state is Invite;

/// Fenêtre « Créez un compte pour [raison] » : le visiteur choisit de créer un
/// compte, de se connecter, ou de rester en démo.
Future<void> demanderConnexion(BuildContext context, {required String raison}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.couleurs.fond,
    builder: (feuille) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 0, AppEspace.gouttiere, AppEspace.l),
        child: _Invitation(raison: raison, onChoix: () => Navigator.of(feuille).pop(), avecPlusTard: true),
      ),
    ),
  );
}

/// Bloc en pleine page à la place d'un écran réservé aux comptes
/// (Portefeuille, Compte, Assistant…).
class ConnexionRequise extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String raison;
  const ConnexionRequise({super.key, required this.icone, required this.titre, required this.raison});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xl, AppEspace.gouttiere, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
            child: Icon(icone, size: 28, color: c.texte),
          ),
          const SizedBox(height: AppEspace.l),
          Text(titre, style: AppTypo.style(taille: 22, graisse: FontWeight.w700, couleur: c.texte, interlettre: -0.3)),
          const SizedBox(height: AppEspace.s),
          _Invitation(raison: raison),
        ],
      ),
    );
  }
}

class _Invitation extends StatelessWidget {
  final String raison;
  final VoidCallback? onChoix;
  final bool avecPlusTard;
  const _Invitation({required this.raison, this.onChoix, this.avecPlusTard = false});

  void _aller(BuildContext context, {required bool creation}) {
    onChoix?.call();
    context.read<AuthBloc>().add(ConnexionDemandee(creation: creation));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Créez un compte gratuit pour $raison. La démo permet seulement de consulter le marché et les analyses.',
            style: AppTypo.style(taille: 15, couleur: c.texteMoyen, hauteur: 1.45)),
        const SizedBox(height: AppEspace.l),
        AppBouton(libelle: 'Créer un compte gratuit', onPressed: () => _aller(context, creation: true)),
        const SizedBox(height: AppEspace.s),
        AppBouton(libelle: 'J’ai déjà un compte', secondaire: true, onPressed: () => _aller(context, creation: false)),
        if (avecPlusTard)
          TextButton(
            onPressed: onChoix,
            child: Text('Continuer la démo', style: AppTypo.style(taille: 15, graisse: FontWeight.w500, couleur: c.texteMoyen)),
          ),
      ],
    );
  }
}

/// Bandeau « Mode démo » en tête du Marché.
class BandeauDemo extends StatelessWidget {
  const BandeauDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.s, AppEspace.gouttiere, AppEspace.s),
      child: Material(
        color: c.encre,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.read<AuthBloc>().add(ConnexionDemandee(creation: true)),
          child: Padding(
            padding: const EdgeInsets.all(AppEspace.m),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, color: c.surEncre, size: 22),
                const SizedBox(width: AppEspace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode démo', style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.surEncre)),
                      const SizedBox(height: 2),
                      Text('Créez un compte pour suivre vos titres, votre portefeuille et recevoir des alertes.',
                          style: AppTypo.style(taille: 13, couleur: c.surEncre.withValues(alpha: 0.75), hauteur: 1.35)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.surEncre),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
