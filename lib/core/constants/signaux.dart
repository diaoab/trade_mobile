import 'package:flutter/material.dart';

import '../theme/app_color.dart';

/// Décisions du moteur (core/engine/decision_engine.py côté API).
enum Signal {
  achat('ACHETER', 'Achat'),
  conserver('CONSERVER', 'Conserver'),
  vente('VENDRE', 'Vente');

  final String code;
  final String libelle;
  const Signal(this.code, this.libelle);

  static Signal? depuis(String? code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }

  Color couleur(AppColor c) => switch (this) {
        Signal.achat => c.hausse,
        Signal.conserver => c.prudence,
        Signal.vente => c.baisse,
      };
}

/// Seuils du moteur de décision : sous 45 vente, à partir de 70 achat.
const double kSeuilConserver = 45;
const double kSeuilAchat = 70;

const String kAvertissement =
    'Outil d’aide à l’analyse. Les signaux sont expérimentaux et ne constituent pas un conseil en investissement.';
