import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typo.dart';

/// Affiché pendant la reprise de la session (lecture du trousseau, /account/me).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('FINANCIAL AI ADVISOR',
                style: AppTypo.style(taille: 13, graisse: FontWeight.w600, couleur: c.texteMoyen, interlettre: 0.4)),
            const SizedBox(height: 24),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
