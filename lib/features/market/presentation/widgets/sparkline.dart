import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';

/// Mini-courbe des derniers mois, couleur selon le sens de la période.
class Sparkline extends StatelessWidget {
  final List<double?> valeurs;
  final double largeur;
  final double hauteur;

  const Sparkline({super.key, required this.valeurs, this.largeur = 64, this.hauteur = 28});

  @override
  Widget build(BuildContext context) {
    final points = valeurs.whereType<double>().toList();
    final couleur = points.length < 2 ? Colors.transparent : context.couleurs.variation(points.last - points.first);
    return CustomPaint(size: Size(largeur, hauteur), painter: _SparklinePainter(points, couleur));
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color couleur;
  _SparklinePainter(this.points, this.couleur);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final ecart = max - min == 0 ? 1 : max - min;
    final chemin = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - 2 - (points[i] - min) / ecart * (size.height - 4);
      i == 0 ? chemin.moveTo(x, y) : chemin.lineTo(x, y);
    }
    canvas.drawPath(
      chemin,
      Paint()
        ..color = couleur
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.points != points || old.couleur != couleur;
}
