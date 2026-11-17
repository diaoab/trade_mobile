import 'package:flutter/material.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';

/// Ouvre la prise en main en plein écran ; [onTerminee] est appelé à la
/// fermeture (bouton ou « Passer »).
Future<void> ouvrirPriseEnMain(BuildContext context, {VoidCallback? onTerminee}) async {
  await Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const PriseEnMainPage(),
  ));
  onTerminee?.call();
}

class _Etape {
  final IconData icone;
  final String titre;
  final String texte;
  final Widget? illustration;
  const _Etape({required this.icone, required this.titre, required this.texte, this.illustration});
}

/// Quatre écrans au premier lancement : ce qu'est un signal, comment le
/// lire, comment suivre ses titres, et ce que l'app n'est pas.
class PriseEnMainPage extends StatefulWidget {
  const PriseEnMainPage({super.key});

  @override
  State<PriseEnMainPage> createState() => _PriseEnMainPageState();
}

class _PriseEnMainPageState extends State<PriseEnMainPage> {
  final _pages = PageController();
  int _index = 0;

  static const _etapes = [
    _Etape(
      icone: Icons.insights_outlined,
      titre: 'Un signal par titre',
      texte: 'Chaque soir, l’app lit plusieurs indicateurs boursiers sur les titres de la BRVM '
          'et résume la situation de chacun en un mot.',
      illustration: _Signaux(),
    ),
    _Etape(
      icone: Icons.speed_outlined,
      titre: 'Un score de 0 à 100',
      texte: 'Sous 45 : Vente. De 45 à 70 : Conserver. À partir de 70 : Achat. '
          'Le score est lissé sur plusieurs séances : il ne change pas de signal sur un seul jour agité. '
          'Touchez un titre pour voir le détail de chaque indicateur.',
    ),
    _Etape(
      icone: Icons.star_outline_rounded,
      titre: 'Suivez vos titres',
      texte: 'Touchez l’étoile d’un titre pour le mettre en favori. Ajoutez vos achats dans Portefeuille. '
          'La cloche vous prévient quand le signal d’un de vos titres change ou qu’un dividende approche.',
    ),
    _Etape(
      icone: Icons.info_outline,
      titre: 'Une aide, pas un conseil',
      texte: 'Les signaux sont calculés automatiquement et restent expérimentaux. Ils ne constituent pas '
          'un conseil en investissement : la décision d’acheter ou de vendre vous appartient.',
    ),
  ];

  bool get _derniere => _index == _etapes.length - 1;

  void _suivant() {
    if (_derniere) {
      Navigator.of(context).pop();
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppEspace.s, top: AppEspace.xs),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Passer', style: AppTypo.style(taille: 15, graisse: FontWeight.w500, couleur: c.texteMoyen)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _etapes.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _PageEtape(etape: _etapes[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _etapes.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? c.texte : c.separateur,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xl, AppEspace.gouttiere, AppEspace.l),
              child: SizedBox(
                width: double.infinity,
                child: AppBouton(libelle: _derniere ? 'Commencer' : 'Suivant', onPressed: _suivant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageEtape extends StatelessWidget {
  final _Etape etape;
  const _PageEtape({required this.etape});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere + 8, vertical: AppEspace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(18)),
            child: Icon(etape.icone, size: 32, color: c.texte),
          ),
          const SizedBox(height: AppEspace.xl),
          Text(etape.titre,
              style: AppTypo.style(taille: 30, graisse: FontWeight.w700, couleur: c.texte, interlettre: -0.5)),
          const SizedBox(height: AppEspace.m),
          Text(etape.texte, style: AppTypo.style(taille: 17, couleur: c.texteMoyen, hauteur: 1.45)),
          if (etape.illustration != null) ...[const SizedBox(height: AppEspace.xl), etape.illustration!],
        ],
      ),
    );
  }
}

/// Les trois signaux et leur couleur.
class _Signaux extends StatelessWidget {
  const _Signaux();

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Column(
      children: [
        for (final s in Signal.values.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppEspace.s),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: s.couleur(c), shape: BoxShape.circle)),
                const SizedBox(width: AppEspace.m),
                Text(s.libelle, style: AppTypo.style(taille: 17, graisse: FontWeight.w600, couleur: s.couleur(c))),
              ],
            ),
          ),
      ],
    );
  }
}
