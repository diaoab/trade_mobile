import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../injection_container.dart';
import '../bloc/reset_password_bloc.dart';

/// Mot de passe oublié : code reçu par e-mail, puis nouveau mot de passe.
/// [email] : adresse déjà saisie sur l'écran de connexion.
class ResetPasswordPage extends StatelessWidget {
  final String email;
  const ResetPasswordPage({super.key, this.email = ''});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<ResetPasswordBloc>(),
    child: _Contenu(email: email),
  );
}

class _Contenu extends StatefulWidget {
  final String email;
  const _Contenu({required this.email});

  @override
  State<_Contenu> createState() => _ContenuState();
}

class _ContenuState extends State<_Contenu> {
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _nouveau = TextEditingController();

  static const _sousTitres = {
    EtapeReinitialisation.email: 'Recevez un code par e-mail pour choisir un nouveau mot de passe.',
    EtapeReinitialisation.code: 'Saisissez le code à 6 chiffres reçu par e-mail.',
    EtapeReinitialisation.nouveau: 'Choisissez votre nouveau mot de passe.',
    EtapeReinitialisation.termine: '',
  };

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _nouveau.dispose();
    super.dispose();
  }

  void _ajouter(ResetPasswordEvent event) {
    FocusScope.of(context).unfocus();
    context.read<ResetPasswordBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.fond, elevation: 0, scrolledUnderElevation: 0),
      // Un nouveau code vide le champ du code précédent.
      body: BlocListener<ResetPasswordBloc, ResetPasswordState>(
        listenWhen: (avant, apres) => apres.codesEnvoyes != avant.codesEnvoyes,
        listener: (_, _) => _code.clear(),
        child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listenWhen: (avant, apres) => apres.etape != avant.etape,
          listener: (context, state) {
            if (state.etape == EtapeReinitialisation.termine) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Mot de passe modifié : reconnectez-vous.')));
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return AppEcran(
              titre: 'Mot de passe oublié',
              sousTitre: _sousTitres[state.etape],
              enfants: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.l, AppEspace.gouttiere, 0),
                  child: switch (state.etape) {
                    EtapeReinitialisation.email => AppChampTexte(
                      libelle: 'Adresse e-mail',
                      controller: _email,
                      clavier: TextInputType.emailAddress,
                      autofill: const [AutofillHints.email],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (v) => _ajouter(CodeDemande(v)),
                    ),
                    EtapeReinitialisation.code => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppChampTexte(
                          libelle: 'Code',
                          controller: _code,
                          clavier: TextInputType.number,
                          autofill: const [AutofillHints.oneTimeCode],
                          indication: '123456',
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (v) => _ajouter(CodeSaisi(v)),
                        ),
                        const SizedBox(height: AppEspace.s),
                        TexteDiscret(
                          'Si un compte existe pour ${state.email}, un code vient d’y être envoyé. '
                          'Il est valable 15 minutes.',
                        ),
                      ],
                    ),
                    _ => AppChampTexte(
                      libelle: 'Nouveau mot de passe',
                      controller: _nouveau,
                      motDePasse: true,
                      indication: '${ResetPasswordBloc.longueurMin} caractères minimum',
                      autofill: const [AutofillHints.newPassword],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (v) => _ajouter(NouveauMotDePasseSaisi(v)),
                    ),
                  },
                ),
                MessageErreur(state.erreur),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.xl, AppEspace.gouttiere, 0),
                  child: switch (state.etape) {
                    EtapeReinitialisation.email => AppBouton(
                      libelle: 'Recevoir un code',
                      enChargement: state.enCours,
                      onPressed: _email.text.trim().isEmpty ? null : () => _ajouter(CodeDemande(_email.text)),
                    ),
                    EtapeReinitialisation.code => AppBouton(
                      libelle: 'Continuer',
                      enChargement: state.enCours,
                      onPressed: _code.text.trim().length != 6 ? null : () => _ajouter(CodeSaisi(_code.text)),
                    ),
                    _ => AppBouton(
                      libelle: 'Changer le mot de passe',
                      enChargement: state.enCours,
                      onPressed: _nouveau.text.isEmpty ? null : () => _ajouter(NouveauMotDePasseSaisi(_nouveau.text)),
                    ),
                  },
                ),
                if (state.etape == EtapeReinitialisation.code) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppLien(
                        libelle: 'Renvoyer le code',
                        onPressed: state.enCours ? null : () => _ajouter(CodeRedemande()),
                      ),
                      AppLien(
                        libelle: 'Changer d’e-mail',
                        onPressed: state.enCours ? null : () => _ajouter(EmailAChanger()),
                      ),
                    ],
                  ),
                ],
                if (state.codesEnvoyes > 1 && state.etape == EtapeReinitialisation.code)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.s, AppEspace.gouttiere, 0),
                    child: Text(
                      'Nouveau code envoyé.',
                      textAlign: TextAlign.center,
                      style: AppTypo.style(taille: 14, couleur: c.texteMoyen),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
