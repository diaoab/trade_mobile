import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/signaux.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/etats.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../billing/presentation/widgets/pro_offer.dart';
import '../../domain/entities/preferences.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_event.dart';
import '../bloc/account_state.dart';
import '../widgets/change_password_section.dart';
import '../widgets/profile_section.dart';

/// Libellés complets des indicateurs (clés de INDICATOR_OPTIONS côté API).
const _libellesIndicateurs = {
  'MM20': 'Moyenne mobile 20 séances',
  'MM50': 'Moyenne mobile 50 séances',
  'RSI': 'RSI (14)',
  'MACD': 'MACD',
  'Bollinger': 'Bandes de Bollinger',
  'Momentum': 'Momentum',
  'Volatilité': 'Volatilité',
};

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;
    return BlocConsumer<AccountBloc, AccountState>(
      listenWhen: (avant, apres) => apres.compteSupprime && !avant.compteSupprime,
      listener: (context, _) => context.read<AuthBloc>().add(LogoutRequested()),
      builder: (context, state) {
        final prefs = state.preferences;
        return AppEcran(
          titre: 'Compte',
          sousTitre: user?.nomAffiche,
          enfants: [
            if (user != null) ProOffer(user: user),
            MessageErreur(state.erreur),
            if (state.chargement) const Chargement(),
            if (user != null) ProfileSection(user: user),
            if (prefs != null) ..._reglages(context, prefs),
            const ChangePasswordSection(),
            AppSection(
              titre: 'Session',
              enfants: [
                AppLigne(
                  onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
                  enfants: [Expanded(child: Text('Se déconnecter', style: AppTypo.style(taille: 16, couleur: context.couleurs.texte)))],
                ),
                AppLigne(
                  derniere: true,
                  onTap: () => _supprimer(context),
                  enfants: [
                    Expanded(child: Text('Supprimer le compte', style: AppTypo.style(taille: 16, couleur: context.couleurs.baisse))),
                  ],
                ),
              ],
            ),
            const NotePied(kAvertissement),
          ],
        );
      },
    );
  }

  Future<void> _supprimer(BuildContext context) async {
    final bloc = context.read<AccountBloc>();
    final ok = await confirmer(
      context,
      titre: 'Supprimer le compte',
      message: 'Votre compte, votre portefeuille et vos réglages seront définitivement supprimés.',
      libelleOk: 'Supprimer',
      danger: true,
    );
    if (ok) bloc.add(DeleteAccountEvent());
  }

  List<Widget> _reglages(BuildContext context, Preferences prefs) {
    final c = context.couleurs;
    final bloc = context.read<AccountBloc>();
    void modifier(ModificationPreferences m) => bloc.add(PreferencesChanged(m));
    return [
      AppSection(
        titre: 'Indicateurs du signal',
        enfants: [
          for (var i = 0; i < prefs.options.length; i++)
            AppLigne(
              derniere: i == prefs.options.length - 1,
              enfants: [
                Expanded(
                  child: Text(_libellesIndicateurs[prefs.options[i]] ?? prefs.options[i],
                      style: AppTypo.style(taille: 16, couleur: c.texte)),
                ),
                Switch.adaptive(
                  value: prefs.indicateurs.contains(prefs.options[i]),
                  onChanged: (actif) => modifier(ModificationPreferences(
                    indicateurs: actif
                        ? [...prefs.indicateurs, prefs.options[i]]
                        : prefs.indicateurs.where((n) => n != prefs.options[i]).toList(),
                  )),
                ),
              ],
            ),
        ],
      ),
      AppSection(
        titre: 'Calculs',
        enfants: [
          AppLigne(
            enfants: [
              const Expanded(
                child: _Libelle(
                  titre: 'Cours ajustés des dividendes',
                  aide: 'Neutralise la baisse mécanique du jour de détachement.',
                ),
              ),
              Switch.adaptive(
                value: prefs.ajusterDividendes,
                onChanged: (v) => modifier(ModificationPreferences(ajusterDividendes: v)),
              ),
            ],
          ),
          AppLigne(
            derniere: true,
            enfants: [
              const Expanded(child: _Libelle(titre: 'Frais d’un aller-retour', aide: 'Commission SGI, redevances et taxes.')),
              _ChampFrais(
                valeur: prefs.fraisAllerRetour,
                onValide: (v) => modifier(ModificationPreferences(fraisAllerRetour: v)),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

class _Libelle extends StatelessWidget {
  final String titre;
  final String aide;
  const _Libelle({required this.titre, required this.aide});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre, style: AppTypo.style(taille: 16, couleur: c.texte)),
        const SizedBox(height: 2),
        Text(aide, style: AppTypo.style(taille: 13, couleur: c.texteMoyen, hauteur: 1.35)),
      ],
    );
  }
}

/// Frais en % : enregistrés à la fin de la saisie.
class _ChampFrais extends StatefulWidget {
  final double valeur;
  final ValueChanged<double> onValide;
  const _ChampFrais({required this.valeur, required this.onValide});

  @override
  State<_ChampFrais> createState() => _ChampFraisState();
}

class _ChampFraisState extends State<_ChampFrais> {
  late final _controleur = TextEditingController(text: Format.nombre(widget.valeur, decimales: widget.valeur % 1 == 0 ? 0 : 2));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _valider();
    });
  }

  void _valider() {
    final v = Format.lireNombre(_controleur.text);
    if (v != null && v != widget.valeur) widget.onValide(v);
  }

  @override
  void dispose() {
    _controleur.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.s)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            child: TextField(
              controller: _controleur,
              focusNode: _focus,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _valider(),
              style: AppTypo.style(taille: 16, couleur: c.texte, tabulaire: true),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            ),
          ),
          const SizedBox(width: 4),
          Text('%', style: AppTypo.style(taille: 16, couleur: c.texteMoyen)),
        ],
      ),
    );
  }
}
