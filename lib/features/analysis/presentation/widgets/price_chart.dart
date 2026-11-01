import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/indicateurs.dart';
import '../../domain/entities/analysis.dart';

/// Périodes proposées, en séances de bourse.
enum Periode {
  unMois('1M', 21),
  troisMois('3M', 63),
  sixMois('6M', 126),
  unAn('1A', 250);

  final String libelle;
  final int seances;
  const Periode(this.libelle, this.seances);
}

const double _hauteur = 220;

/// Cours avec choix de la période, moyennes mobiles et bandes de Bollinger
/// en option, et curseur au doigt qui affiche la séance pointée.
class PriceChart extends StatefulWidget {
  final SeriesGraphique graphique;
  const PriceChart({super.key, required this.graphique});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  Periode _periode = Periode.sixMois;
  bool _mm20 = true;
  bool _mm50 = true;
  bool _bollinger = false;
  int? _curseur;

  List<T> _fin<T>(List<T> valeurs) => valeurs.length <= _periode.seances ? valeurs : valeurs.sublist(valeurs.length - _periode.seances);

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final g = widget.graphique;
    final dates = _fin(g.dates);
    final cours = _fin(g['Close']);
    final n = cours.length;
    if (n < 2) return const SizedBox.shrink();

    final donnees = _Donnees(
      cours: cours,
      mm20: _mm20 ? _fin(g['MM20']) : const [],
      mm50: _mm50 ? _fin(g['MM50']) : const [],
      haut: _bollinger ? _fin(g['Bollinger_Upper']) : const [],
      bas: _bollinger ? _fin(g['Bollinger_Lower']) : const [],
    );
    final affiches = donnees.toutes.whereType<double>();
    if (affiches.isEmpty) return const SizedBox.shrink();

    final premier = cours.whereType<double>().first;
    final dernier = cours.last ?? premier;
    final couleurLigne = c.variation(dernier - premier);
    final mini = affiches.reduce(math.min);
    final maxi = affiches.reduce(math.max);
    final pointe = _curseur == null ? null : cours[_curseur!];
    final variationPeriode = premier == 0 ? null : (dernier - premier) / premier * 100;

    void suivre(double x, double largeur) =>
        setState(() => _curseur = (x / largeur * (n - 1)).round().clamp(0, n - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 0, AppEspace.gouttiere, AppEspace.s),
          child: SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: pointe != null
                  ? Text.rich(TextSpan(children: [
                      TextSpan(text: '${Format.nombre(pointe)} FCFA', style: TextStyle(color: c.texte)),
                      TextSpan(text: '  ${Format.date(dates[_curseur!])}', style: TextStyle(color: c.texteMoyen)),
                    ]), style: AppTypo.style(taille: 15, graisse: FontWeight.w500, tabulaire: true))
                  : Text.rich(TextSpan(children: [
                      TextSpan(text: 'Sur la période  ', style: TextStyle(color: c.texteMoyen)),
                      TextSpan(text: Format.pourcentage(variationPeriode), style: TextStyle(color: c.variation(variationPeriode))),
                    ]), style: AppTypo.style(taille: 15, graisse: FontWeight.w500, tabulaire: true)),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, contraintes) {
            final largeur = contraintes.maxWidth;
            // Curseur au glissement horizontal seulement : un geste vertical
            // reste un défilement de la page.
            return GestureDetector(
              onHorizontalDragStart: (d) => suivre(d.localPosition.dx, largeur),
              onHorizontalDragUpdate: (d) => suivre(d.localPosition.dx, largeur),
              onHorizontalDragEnd: (_) => setState(() => _curseur = null),
              onHorizontalDragCancel: () => setState(() => _curseur = null),
              child: CustomPaint(
                size: Size(largeur, _hauteur),
                painter: _GraphiquePainter(
                  donnees: donnees,
                  mini: mini,
                  maxi: maxi,
                  couleurLigne: couleurLigne,
                  c: c,
                  curseur: _curseur,
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 6, AppEspace.gouttiere, 0),
          child: DefaultTextStyle(
            style: AppTypo.style(taille: 12, couleur: c.texteFaible, tabulaire: true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Format.dateCourte(dates.first)),
                Text('${Format.nombre(mini)} – ${Format.nombre(maxi)}'),
                Text(Format.dateCourte(dates.last)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Segmente<Periode>(
          options: Periode.values,
          valeur: _periode,
          libelle: (p) => p.libelle,
          onChanged: (p) => setState(() => _periode = p),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.m, AppEspace.gouttiere, 0),
          child: Wrap(
            spacing: AppEspace.s,
            children: [
              _Bascule(libelle: 'MM20', actif: _mm20, couleur: c.serie1, onTap: () => setState(() => _mm20 = !_mm20)),
              _Bascule(libelle: 'MM50', actif: _mm50, couleur: c.serie2, onTap: () => setState(() => _mm50 = !_mm50)),
              _Bascule(
                  libelle: 'Bollinger',
                  actif: _bollinger,
                  couleur: c.texteFaible,
                  bande: true,
                  onTap: () => setState(() => _bollinger = !_bollinger)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Donnees {
  final List<double?> cours, mm20, mm50, haut, bas;
  const _Donnees({required this.cours, required this.mm20, required this.mm50, required this.haut, required this.bas});

  Iterable<double?> get toutes => [...cours, ...mm20, ...mm50, ...haut, ...bas];
}

class _GraphiquePainter extends CustomPainter {
  final _Donnees donnees;
  final double mini, maxi;
  final Color couleurLigne;
  final AppColor c;
  final int? curseur;

  _GraphiquePainter({
    required this.donnees,
    required this.mini,
    required this.maxi,
    required this.couleurLigne,
    required this.c,
    required this.curseur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = donnees.cours.length;
    final marge = (maxi - mini) * 0.08 == 0 ? 1 : (maxi - mini) * 0.08;
    double x(int i) => i / (n - 1) * size.width;
    double y(double v) => 8 + (1 - (v - mini + marge) / (maxi - mini + 2 * marge)) * (size.height - 16);

    Path ligne(List<double?> valeurs) {
      final chemin = Path();
      var plume = false;
      for (var i = 0; i < valeurs.length; i++) {
        final v = valeurs[i];
        if (v == null) {
          plume = false;
          continue;
        }
        plume ? chemin.lineTo(x(i), y(v)) : chemin.moveTo(x(i), y(v));
        plume = true;
      }
      return chemin;
    }

    Paint trait(Color couleur, double epaisseur) => Paint()
      ..color = couleur
      ..strokeWidth = epaisseur
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // Bande de Bollinger : contour haut puis bas parcouru à l'envers.
    if (donnees.haut.length == n && donnees.bas.length == n) {
      final indices = [for (var i = 0; i < n; i++) if (donnees.haut[i] != null && donnees.bas[i] != null) i];
      if (indices.isNotEmpty) {
        final bande = Path()..moveTo(x(indices.first), y(donnees.haut[indices.first]!));
        for (final i in indices.skip(1)) {
          bande.lineTo(x(i), y(donnees.haut[i]!));
        }
        for (final i in indices.reversed) {
          bande.lineTo(x(i), y(donnees.bas[i]!));
        }
        canvas.drawPath(bande..close(), Paint()..color = c.bande);
      }
    }

    final cours = ligne(donnees.cours);
    final aire = Path.from(cours)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      aire,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [couleurLigne.withValues(alpha: 0.16), couleurLigne.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    if (donnees.mm50.isNotEmpty) canvas.drawPath(ligne(donnees.mm50), trait(c.serie2, 1.2));
    if (donnees.mm20.isNotEmpty) canvas.drawPath(ligne(donnees.mm20), trait(c.serie1, 1.2));
    canvas.drawPath(cours, trait(couleurLigne, 2));

    final i = curseur;
    final pointe = i == null ? null : donnees.cours[i];
    if (i != null && pointe != null) {
      canvas.drawLine(Offset(x(i), 0), Offset(x(i), size.height), trait(c.texteFaible, 1));
      canvas.drawCircle(Offset(x(i), y(pointe)), 6.5, Paint()..color = c.fond);
      canvas.drawCircle(Offset(x(i), y(pointe)), 4.5, Paint()..color = couleurLigne);
    }
  }

  @override
  bool shouldRepaint(_GraphiquePainter old) =>
      old.donnees != donnees || old.curseur != curseur || old.couleurLigne != couleurLigne || old.c != c;
}

/// Superposition activable : puce avec l'échantillon de trait, pleine quand
/// la courbe est affichée.
class _Bascule extends StatelessWidget {
  final String libelle;
  final bool actif;
  final Color couleur;
  final bool bande;
  final VoidCallback onTap;

  const _Bascule({required this.libelle, required this.actif, required this.couleur, required this.onTap, this.bande = false});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Semantics(
      toggled: actif,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: actif ? c.surface : Colors.transparent,
            border: Border.all(color: actif ? c.surface : c.separateur),
            borderRadius: BorderRadius.circular(AppRayon.s),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: bande ? 9 : 2,
                decoration: BoxDecoration(
                  color: bande ? (actif ? c.bande : Colors.transparent) : (actif ? couleur : c.texteFaible),
                  border: bande ? Border.all(color: couleur) : null,
                  borderRadius: BorderRadius.circular(bande ? 2 : 1),
                ),
              ),
              const SizedBox(width: 6),
              Text(libelle,
                  style: AppTypo.style(taille: 13, graisse: FontWeight.w500, couleur: actif ? c.texte : c.texteFaible)),
            ],
          ),
        ),
      ),
    );
  }
}
