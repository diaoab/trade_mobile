import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/etats.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Connexion, création de compte, ou entrée en démo sans compte.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  late bool _creation;

  @override
  void initState() {
    super.initState();
    final etat = context.read<AuthBloc>().state;
    _creation = etat is Unauthenticated && etat.creation;
  }

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  bool get _complet => _email.text.trim().isNotEmpty && _motDePasse.text.isNotEmpty;

  void _soumettre() {
    if (!_complet) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginRequested(email: _email.text, motDePasse: _motDePasse.text, creation: _creation));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.9, -1.1),
            radius: 1.2,
            colors: [c.encre.withValues(alpha: 0.18), c.fond],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final enCours = state is AuthLoading;
              return AutofillGroup(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kLargeurMax),
                    child: ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.l, AppEspace.gouttiere, 32),
                      children: [
                        const _Marque(),
                        const SizedBox(height: AppEspace.xl),
                        Text(
                          'Les marchés de la BRVM, lus pour vous.',
                          style: AppTypo.style(
                            taille: 30,
                            graisse: FontWeight.w700,
                            couleur: c.texte,
                            interlettre: -0.8,
                            hauteur: 1.15,
                          ),
                        ),
                        const SizedBox(height: AppEspace.m),
                        Text(
                          'Un signal clair par titre chaque soir, votre portefeuille et vos dividendes au même endroit.',
                          style: AppTypo.style(taille: 16, couleur: c.texteMoyen, hauteur: 1.45),
                        ),
                        const SizedBox(height: AppEspace.xl),
                        const _Apercu(),
                        const SizedBox(height: 28),
                        _Bascule(
                          creation: _creation,
                          onChange: enCours ? null : (creation) => setState(() => _creation = creation),
                        ),
                        const SizedBox(height: AppEspace.xl),
                        AppChampTexte(
                          libelle: 'Adresse e-mail',
                          controller: _email,
                          icone: Icons.mail_outline,
                          indication: 'vous@exemple.com',
                          clavier: TextInputType.emailAddress,
                          autofill: const [AutofillHints.email],
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        AppChampTexte(
                          libelle: 'Mot de passe',
                          controller: _motDePasse,
                          icone: Icons.lock_outline,
                          motDePasse: true,
                          indication: _creation ? '8 caractères minimum' : null,
                          autofill: [_creation ? AutofillHints.newPassword : AutofillHints.password],
                          onSubmitted: (_) => _soumettre(),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (!_creation)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: AppEspace.xs),
                              child: AppLien(
                                libelle: 'Mot de passe oublié ?',
                                couleur: c.texteMoyen,
                                onPressed: enCours
                                    ? null
                                    : () =>
                                          Navigator.of(context)
                                              .pushNamed(AppRouter.resetPasswordRoute, arguments: _email.text.trim()),
                              ),
                            ),
                          ),
                        if (state is Unauthenticated && state.erreur != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppEspace.m),
                            child: _Erreur(state.erreur!),
                          ),
                        const SizedBox(height: AppEspace.l),
                        AppBouton(
                          libelle: _creation ? 'Créer mon compte' : 'Se connecter',
                          enChargement: enCours,
                          onPressed: _complet ? _soumettre : null,
                        ),
                        const SizedBox(height: AppEspace.xl),
                        const _Separateur(),
                        const SizedBox(height: AppEspace.xl),
                        AppBouton(
                          libelle: 'Découvrir sans compte',
                          secondaire: true,
                          onPressed: enCours ? null : () => context.read<AuthBloc>().add(ContinuerSansCompte()),
                        ),
                        const SizedBox(height: AppEspace.s),
                        Text(
                          'Démo du marché et des analyses, en lecture seule.',
                          textAlign: TextAlign.center,
                          style: AppTypo.style(taille: 13, couleur: c.texteFaible),
                        ),
                        const NotePied(kAvertissement),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Logo dessiné (courbe montante sur fond d'encre) et nom de l'app.
class _Marque extends StatelessWidget {
  const _Marque();

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: c.encre, borderRadius: BorderRadius.circular(12)),
          child: CustomPaint(painter: _CourbeLogo(c.surEncre, c.surEncre)),
        ),
        const SizedBox(width: AppEspace.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial AI Advisor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypo.style(taille: 16, graisse: FontWeight.w700, couleur: c.texte),
              ),
              Text(
                'Bourse régionale · BRVM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypo.style(taille: 12, couleur: c.texteMoyen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourbeLogo extends CustomPainter {
  final Color trait;
  final Color point;
  _CourbeLogo(this.trait, this.point);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final chemin = Path()
      ..moveTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.42, h * 0.48)
      ..lineTo(w * 0.56, h * 0.58)
      ..lineTo(w * 0.76, h * 0.32);
    canvas.drawPath(
      chemin,
      Paint()
        ..color = trait
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(Offset(w * 0.76, h * 0.32), w * 0.075, Paint()..color = point);
  }

  @override
  bool shouldRepaint(covariant _CourbeLogo old) => old.trait != trait || old.point != point;
}

/// Illustration du produit : une courbe de cours et les trois signaux.
class _Apercu extends StatelessWidget {
  const _Apercu();

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppEspace.l, AppEspace.l, AppEspace.l, AppEspace.m),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 56, child: CustomPaint(painter: _CourbeApercu(c.hausse, c.separateur))),
          const SizedBox(height: AppEspace.m),
          Row(
            children: [
              for (final s in Signal.values) ...[
                if (s != Signal.values.first) const SizedBox(width: AppEspace.s),
                Expanded(child: _Pastille(signal: s)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  final Signal signal;
  const _Pastille({required this.signal});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final couleur = signal.couleur(c);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: couleur.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      // Grand texte ou écran étroit : la pastille rétrécit plutôt que de déborder.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              signal.libelle,
              style: AppTypo.style(taille: 13, graisse: FontWeight.w600, couleur: couleur),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourbeApercu extends CustomPainter {
  final Color couleur;
  final Color grille;
  _CourbeApercu(this.couleur, this.grille);

  // Forme décorative, pas des cours réels.
  static const _points = [0.62, 0.55, 0.6, 0.48, 0.52, 0.4, 0.45, 0.33, 0.37, 0.26, 0.3, 0.18];

  @override
  void paint(Canvas canvas, Size size) {
    final ligneGrille = Paint()
      ..color = grille
      ..strokeWidth = 1;
    for (final y in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * y), Offset(size.width, size.height * y), ligneGrille);
    }
    final pas = size.width / (_points.length - 1);
    final courbe = Path()..moveTo(0, size.height * _points.first);
    for (var i = 1; i < _points.length; i++) {
      courbe.lineTo(pas * i, size.height * _points[i]);
    }
    final aire = Path.from(courbe)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      aire,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [couleur.withValues(alpha: 0.22), couleur.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      courbe,
      Paint()
        ..color = couleur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(size.width, size.height * _points.last), 4.5, Paint()..color = couleur);
  }

  @override
  bool shouldRepaint(covariant _CourbeApercu old) => old.couleur != couleur || old.grille != grille;
}

/// Choix Connexion / Créer un compte, en pastille.
class _Bascule extends StatelessWidget {
  final bool creation;
  final ValueChanged<bool>? onChange;
  const _Bascule({required this.creation, this.onChange});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    Widget option(String libelle, bool valeur) {
      final actif = creation == valeur;
      return Expanded(
        child: Semantics(
          button: true,
          selected: actif,
          child: GestureDetector(
            onTap: onChange == null ? null : () => onChange!(valeur),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: actif ? c.champ : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: actif ? c.separateur : Colors.transparent),
              ),
              child: Text(
                libelle,
                textAlign: TextAlign.center,
                style: AppTypo.style(taille: 15, graisse: FontWeight.w600, couleur: actif ? c.texte : c.texteMoyen),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [option('Connexion', false), option('Créer un compte', true)]),
    );
  }
}

class _Erreur extends StatelessWidget {
  final String message;
  const _Erreur(this.message);

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Container(
      padding: const EdgeInsets.all(AppEspace.m),
      decoration: BoxDecoration(color: c.baisse.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: c.baisse),
          const SizedBox(width: AppEspace.s),
          Expanded(
            child: Text(message, style: AppTypo.style(taille: 14, couleur: c.baisse, hauteur: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Row(
      children: [
        Expanded(child: Divider(color: c.separateur, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppEspace.m),
          child: Text('ou', style: AppTypo.style(taille: 13, couleur: c.texteFaible)),
        ),
        Expanded(child: Divider(color: c.separateur, height: 1)),
      ],
    );
  }
}
