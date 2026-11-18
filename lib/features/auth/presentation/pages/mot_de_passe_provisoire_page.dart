import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../injection_container.dart';
import '../../../account/domain/usecases/change_password.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Première connexion d'un compte créé par l'administration : le mot de
/// passe reçu est provisoire, il faut en choisir un avant d'entrer dans l'app.
class MotDePasseProvisoirePage extends StatefulWidget {
  const MotDePasseProvisoirePage({super.key});

  @override
  State<MotDePasseProvisoirePage> createState() => _MotDePasseProvisoirePageState();
}

class _MotDePasseProvisoirePageState extends State<MotDePasseProvisoirePage> {
  final _provisoire = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirmation = TextEditingController();
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _provisoire.dispose();
    _nouveau.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  bool get _complet => _provisoire.text.isNotEmpty && _nouveau.text.length >= 8 && _confirmation.text.isNotEmpty;

  Future<void> _valider() async {
    if (_nouveau.text != _confirmation.text) {
      setState(() => _erreur = 'Les deux mots de passe ne correspondent pas.');
      return;
    }
    if (_nouveau.text == _provisoire.text) {
      setState(() => _erreur = 'Choisis un mot de passe différent du mot de passe provisoire.');
      return;
    }
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    final auth = context.read<AuthBloc>();
    final resultat = await sl<ChangePassword>()(_provisoire.text, _nouveau.text);
    if (!mounted) return;
    resultat.fold(
      (f) => setState(() {
        _envoi = false;
        _erreur = f.errorMessage;
      }),
      // Le compte relu n'a plus de mot de passe provisoire : direction l'accueil.
      (_) => auth.add(UserRefreshRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final auth = context.watch<AuthBloc>().state;
    final email = auth is Authenticated ? auth.user.email : '';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xxl, AppEspace.gouttiere, AppEspace.xl),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.encre.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.lock_reset_rounded, color: c.encre, size: 30),
                ),
                const SizedBox(height: AppEspace.l),
                Text('Choisis ton mot de passe',
                    style: AppTypo.style(taille: 26, graisse: FontWeight.w700, couleur: c.texte)),
                const SizedBox(height: AppEspace.s),
                Text(
                  'Ton compte $email a été créé avec un mot de passe provisoire. '
                  'Remplace-le par un mot de passe personnel pour continuer.',
                  style: AppTypo.style(taille: 15, couleur: c.texteMoyen, hauteur: 1.4),
                ),
                const SizedBox(height: AppEspace.xl),
                AppChampTexte(
                  libelle: 'Mot de passe provisoire',
                  controller: _provisoire,
                  motDePasse: true,
                  autofill: const [AutofillHints.password],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                AppChampTexte(
                  libelle: 'Nouveau mot de passe',
                  controller: _nouveau,
                  motDePasse: true,
                  indication: '8 caractères minimum',
                  autofill: const [AutofillHints.newPassword],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                AppChampTexte(
                  libelle: 'Confirmer le nouveau mot de passe',
                  controller: _confirmation,
                  motDePasse: true,
                  autofill: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _complet ? _valider() : null,
                  onChanged: (_) => setState(() {}),
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: AppEspace.m),
                  Text(_erreur!, style: AppTypo.style(taille: 15, couleur: c.baisse)),
                ],
                const SizedBox(height: AppEspace.xl),
                AppBouton(libelle: 'Enregistrer et continuer', enChargement: _envoi, onPressed: _complet ? _valider : null),
                const SizedBox(height: AppEspace.m),
                Center(
                  child: AppLien(
                    libelle: 'Se déconnecter',
                    couleur: c.texteMoyen,
                    onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
