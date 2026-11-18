import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_typo.dart';
import '../utils/format.dart';
import '../utils/fraicheur.dart';

/// Avertit que les cours affichés ne sont pas à jour : les signaux et la
/// valorisation portent sur la séance [date]. Rien si les cours sont récents.
class BandeauCoursAnciens extends StatelessWidget {
  final String? date;

  /// Ce que la date ancienne concerne sur cet écran (« Les signaux et les
  /// cours », « La valorisation »…).
  final String portee;

  /// Pour les tests : date du jour.
  final DateTime? maintenant;

  /// Bouton « Récupérer les cours du jour » (absent si null).
  final VoidCallback? onRecuperer;
  final bool recuperation;

  const BandeauCoursAnciens({
    super.key,
    required this.date,
    this.portee = 'Les cours et les signaux',
    this.maintenant,
    this.onRecuperer,
    this.recuperation = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!Fraicheur.estAncienne(date, maintenant: maintenant)) return const SizedBox.shrink();
    final c = context.couleurs;
    final retard = Fraicheur.seancesDeRetard(date, maintenant: maintenant)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.s, AppEspace.gouttiere, AppEspace.s),
      child: Semantics(
        container: true,
        label: 'Avertissement',
        child: Container(
          padding: const EdgeInsets.all(AppEspace.m),
          decoration: BoxDecoration(
            color: c.prudence.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.prudence.withValues(alpha: 0.45)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: c.prudence),
              const SizedBox(width: AppEspace.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cours non à jour',
                        style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: c.texte)),
                    const SizedBox(height: 2),
                    Text(
                      '$portee datent de la séance du ${Format.date(date)}, '
                      'soit $retard séances de retard. Ils ne reflètent pas le marché d’aujourd’hui.',
                      style: AppTypo.style(taille: 13, couleur: c.texteMoyen, hauteur: 1.4),
                    ),
                    if (onRecuperer != null) ...[
                      const SizedBox(height: AppEspace.s),
                      BoutonCoursDuJour(onPressed: onRecuperer!, enCours: recuperation),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Récupérer les cours du jour » : lit les cours de la séance sur Sika Finance.
class BoutonCoursDuJour extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enCours;
  const BoutonCoursDuJour({super.key, required this.onPressed, this.enCours = false});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return TextButton.icon(
      onPressed: enCours ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: c.encre,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: c.encre.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: enCours
          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.encre))
          : const Icon(Icons.download_rounded, size: 18),
      label: Text(enCours ? 'Récupération…' : 'Récupérer les cours du jour',
          style: AppTypo.style(taille: 14, graisse: FontWeight.w600, couleur: c.encre)),
    );
  }
}
