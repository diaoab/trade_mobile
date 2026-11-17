import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

/// Prénom, nom et téléphone du compte. Un champ vidé est effacé.
class ProfileSection extends StatefulWidget {
  final User user;
  const ProfileSection({super.key, required this.user});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late final _prenom = TextEditingController(text: widget.user.prenom);
  late final _nom = TextEditingController(text: widget.user.nom);
  late final _telephone = TextEditingController(text: widget.user.telephone);
  bool _ouvert = false;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _telephone.dispose();
    super.dispose();
  }

  void _ouvrir() => setState(() {
    _prenom.text = widget.user.prenom ?? '';
    _nom.text = widget.user.nom ?? '';
    _telephone.text = widget.user.telephone ?? '';
    _ouvert = true;
  });

  void _enregistrer() {
    FocusScope.of(context).unfocus();
    context.read<AccountBloc>().add(ProfileChanged(prenom: _prenom.text, nom: _nom.text, telephone: _telephone.text));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final u = widget.user;
    return BlocConsumer<AccountBloc, AccountState>(
      listenWhen: (avant, apres) => apres.profilModifie != null && apres.profilModifie != avant.profilModifie,
      listener: (context, state) {
        // Le compte affiché partout (en-tête, offre) suit la modification.
        context.read<AuthBloc>().add(UserUpdated(state.profilModifie!));
        setState(() => _ouvert = false);
      },
      builder: (context, state) => AppSection(
        titre: 'Profil',
        enfants: [
          if (!_ouvert) ...[
            _Ligne(libelle: 'Prénom', valeur: u.prenom),
            _Ligne(libelle: 'Nom', valeur: u.nom),
            _Ligne(libelle: 'Téléphone', valeur: u.telephone),
            AppLigne(
              derniere: true,
              onTap: _ouvrir,
              enfants: [
                Expanded(
                  child: Text('Modifier le profil', style: AppTypo.style(taille: 16, couleur: c.texte)),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: 14),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppChampTexte(libelle: 'Prénom', controller: _prenom, autofill: const [AutofillHints.givenName]),
                    const SizedBox(height: 14),
                    AppChampTexte(libelle: 'Nom', controller: _nom, autofill: const [AutofillHints.familyName]),
                    const SizedBox(height: 14),
                    AppChampTexte(
                      libelle: 'Téléphone',
                      controller: _telephone,
                      clavier: TextInputType.phone,
                      autofill: const [AutofillHints.telephoneNumber],
                      onSubmitted: (_) => _enregistrer(),
                    ),
                    if (state.erreurProfil != null) ...[
                      const SizedBox(height: AppEspace.s),
                      Text(state.erreurProfil!, style: AppTypo.style(taille: 15, couleur: c.baisse)),
                    ],
                    const SizedBox(height: 14),
                    AppBouton(libelle: 'Enregistrer', enChargement: state.profilEnCours, onPressed: _enregistrer),
                    const SizedBox(height: AppEspace.s),
                    AppLien(
                      libelle: 'Annuler',
                      onPressed: state.profilEnCours ? null : () => setState(() => _ouvert = false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final String libelle;
  final String? valeur;
  const _Ligne({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return AppLigne(
      enfants: [
        Expanded(
          child: Text(libelle, style: AppTypo.style(taille: 16, couleur: c.texte)),
        ),
        Text(valeur ?? '—', style: AppTypo.style(taille: 16, couleur: c.texteMoyen)),
      ],
    );
  }
}
