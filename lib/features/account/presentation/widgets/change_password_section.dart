import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';

class ChangePasswordSection extends StatefulWidget {
  const ChangePasswordSection({super.key});

  @override
  State<ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  final _actuel = TextEditingController();
  final _nouveau = TextEditingController();
  bool _ouvert = false;
  bool _fait = false;

  @override
  void dispose() {
    _actuel.dispose();
    _nouveau.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (_actuel.text.isEmpty || _nouveau.text.isEmpty) return;
    context.read<AccountBloc>().add(ChangePasswordEvent(actuel: _actuel.text, nouveau: _nouveau.text));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return BlocConsumer<AccountBloc, AccountState>(
      listenWhen: (avant, apres) => apres.motsDePasseChanges > avant.motsDePasseChanges,
      listener: (context, _) => setState(() {
        _actuel.clear();
        _nouveau.clear();
        _ouvert = false;
        _fait = true;
      }),
      builder: (context, state) => AppSection(
        titre: 'Mot de passe',
        enfants: [
          if (!_ouvert)
            AppLigne(
              derniere: true,
              onTap: () => setState(() {
                _ouvert = true;
                _fait = false;
              }),
              enfants: [
                Expanded(
                  child: Text(_fait ? 'Mot de passe modifié ✓' : 'Changer le mot de passe',
                      style: AppTypo.style(taille: 16, couleur: c.texte)),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere, vertical: 14),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppChampTexte(
                      libelle: 'Mot de passe actuel',
                      controller: _actuel,
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
                      onSubmitted: (_) => _enregistrer(),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (state.erreurMotDePasse != null) ...[
                      const SizedBox(height: AppEspace.s),
                      Text(state.erreurMotDePasse!, style: AppTypo.style(taille: 15, couleur: c.baisse)),
                    ],
                    const SizedBox(height: 14),
                    const TexteDiscret('Les autres appareils connectés seront déconnectés.'),
                    const SizedBox(height: 14),
                    AppBouton(
                      libelle: 'Enregistrer',
                      enChargement: state.motDePasseEnCours,
                      onPressed: _actuel.text.isEmpty || _nouveau.text.isEmpty ? null : _enregistrer,
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
