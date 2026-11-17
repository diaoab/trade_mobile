import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/etats.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _creation = false;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (_email.text.trim().isEmpty || _motDePasse.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginRequested(email: _email.text, motDePasse: _motDePasse.text, creation: _creation));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final enCours = state is AuthLoading;
          return AutofillGroup(
            child: AppEcran(
              enfants: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 40, AppEspace.gouttiere, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FINANCIAL AI ADVISOR',
                          style: AppTypo.style(taille: 13, graisse: FontWeight.w600, couleur: c.texteMoyen, interlettre: 0.4)),
                      const SizedBox(height: 10),
                      Text(_creation ? 'Créer un compte' : 'Connexion',
                          style: AppTypo.style(taille: 34, graisse: FontWeight.w700, couleur: c.texte, interlettre: -0.6)),
                      const SizedBox(height: 10),
                      Text(
                        'Signaux techniques, suivi de portefeuille et calendrier des dividendes pour les titres de la BRVM.',
                        style: AppTypo.style(taille: 16, couleur: c.texteMoyen, hauteur: 1.45),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, 36, AppEspace.gouttiere, 0),
                  child: Column(
                    children: [
                      AppChampTexte(
                        libelle: 'Adresse e-mail',
                        controller: _email,
                        clavier: TextInputType.emailAddress,
                        autofill: const [AutofillHints.email],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      AppChampTexte(
                        libelle: 'Mot de passe',
                        controller: _motDePasse,
                        motDePasse: true,
                        indication: _creation ? '8 caractères minimum' : null,
                        autofill: [_creation ? AutofillHints.newPassword : AutofillHints.password],
                        onSubmitted: (_) => _soumettre(),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (!_creation)
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppLien(
                            libelle: 'Mot de passe oublié ?',
                            onPressed: enCours
                                ? null
                                : () => Navigator.of(context).pushNamed(AppRouter.resetPasswordRoute, arguments: _email.text.trim()),
                          ),
                        ),
                    ],
                  ),
                ),
                if (state is Unauthenticated) MessageErreur(state.erreur),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xl, AppEspace.gouttiere, 0),
                  child: AppBouton(
                    libelle: _creation ? 'Créer mon compte' : 'Se connecter',
                    enChargement: enCours,
                    onPressed: _email.text.trim().isEmpty || _motDePasse.text.isEmpty ? null : _soumettre,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_creation ? 'Déjà inscrit ?' : 'Pas encore de compte ?',
                        style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
                    const SizedBox(width: 6),
                    AppLien(
                      libelle: _creation ? 'Se connecter' : 'Créer un compte',
                      onPressed: enCours ? null : () => setState(() => _creation = !_creation),
                    ),
                  ],
                ),
                const NotePied(kAvertissement),
              ],
            ),
          );
        },
      ),
    );
  }
}
