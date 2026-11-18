import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/etats.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/billing_bloc.dart';

/// Offre Pro. La page de paiement PayDunya s'ouvre dans le navigateur ; au
/// retour dans l'app, l'API vérifie la facture avant d'activer l'offre.
class ProOffer extends StatefulWidget {
  final User user;
  const ProOffer({super.key, required this.user});

  @override
  State<ProOffer> createState() => _ProOfferState();
}

class _ProOfferState extends State<ProOffer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    if (etat == AppLifecycleState.resumed) context.read<BillingBloc>().add(RetourPaiement());
  }

  Future<void> _ouvrir(String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d’ouvrir la page de paiement.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillingBloc, BillingState>(
      listenWhen: (avant, apres) => apres.urlAOuvrir != null || (apres.statutConfirme != null && avant.statutConfirme != apres.statutConfirme),
      listener: (context, state) {
        if (state.urlAOuvrir != null) _ouvrir(state.urlAOuvrir!);
        if (state.statutConfirme != null) context.read<AuthBloc>().add(UserRefreshRequested());
      },
      builder: (context, state) => widget.user.estPro ? _actif(context, state) : _publicite(context, state),
    );
  }

  Widget _actif(BuildContext context, BillingState state) {
    final c = context.couleurs;
    final u = widget.user;
    return AppSection(
      titre: 'Abonnement',
      enfants: [
        AppLigne(
          derniere: true,
          enfants: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offre Pro', style: AppTypo.style(taille: 16, graisse: FontWeight.w600, couleur: c.texte)),
                  const SizedBox(height: 2),
                  Text(
                    '${u.proJusquau != null ? 'Active jusqu’au ${Format.date(u.proJusquau)}' : 'Active'} · '
                    '${u.assistant.limite} questions par jour',
                    style: AppTypo.style(taille: 13, couleur: c.texteMoyen),
                  ),
                ],
              ),
            ),
            AppLien(
              libelle: state.enCours ? '…' : 'Prolonger',
              onPressed: state.enCours ? null : () => context.read<BillingBloc>().add(SouscriptionDemandee()),
            ),
          ],
        ),
        if (state.avis != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
            child: TexteDiscret(state.avis!, couleur: c.hausse),
          ),
        MessageErreur(state.erreur),
      ],
    );
  }

  Widget _publicite(BuildContext context, BillingState state) {
    final c = context.couleurs;
    final offre = state.offre;
    TextStyle sur(double taille, {FontWeight graisse = FontWeight.w400, double opacite = 1}) =>
        AppTypo.style(taille: taille, graisse: graisse, couleur: c.texte.withValues(alpha: opacite), hauteur: 1.4);
    return Container(
      margin: const EdgeInsets.fromLTRB(AppEspace.carte, 20, AppEspace.carte, 0),
      padding: const EdgeInsets.all(20),
      // Carte sombre teintée de turquoise : mise en avant sans éblouir.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.encre.withValues(alpha: 0.28), c.surface],
        ),
        borderRadius: BorderRadius.circular(AppRayon.carte),
        border: Border.all(color: c.encre.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OFFRE PRO', style: sur(12, graisse: FontWeight.w700).copyWith(letterSpacing: 1, color: c.encre)),
          const SizedBox(height: AppEspace.s),
          Text('${offre != null ? '${offre.limiteAssistant} questions par jour' : 'Plus de questions'} à l’assistant',
              style: sur(22, graisse: FontWeight.w700).copyWith(letterSpacing: -0.4, height: 1.2)),
          const SizedBox(height: 6),
          Text(
            'Au lieu de ${widget.user.assistant.limite} avec l’offre gratuite, et portefeuille et favoris sans limite'
            '${_limitesGratuites(widget.user.limites)}. Paiement par Orange Money, Wave, MTN, Moov ou carte via PayDunya.',
            style: sur(14, opacite: 0.7),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (offre != null)
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: '${Format.nombre(offre.prix)} FCFA', style: sur(20, graisse: FontWeight.w700)),
                    TextSpan(text: ' / ${offre.jours} jours', style: sur(14)),
                  ])),
                )
              else
                const Spacer(),
              Opacity(
                opacity: offre?.disponible == true ? 1 : 0.4,
                child: FilledButton(
                  onPressed: offre?.disponible == true && !state.enCours
                      ? () => context.read<BillingBloc>().add(SouscriptionDemandee())
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.encre,
                    disabledBackgroundColor: c.encre,
                    foregroundColor: c.surEncre,
                    disabledForegroundColor: c.surEncre,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRayon.m)),
                  ),
                  child: state.enCours
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.surEncre))
                      : const Text('Passer Pro', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
          if (offre != null && !offre.disponible) ...[
            const SizedBox(height: 10),
            Text('Paiement bientôt disponible.', style: sur(14, opacite: 0.7)),
          ],
          if (state.avis != null) ...[
            const SizedBox(height: 10),
            Text(state.avis!, style: sur(14, opacite: 0.85)),
          ],
          if (state.erreur != null) ...[
            const SizedBox(height: 10),
            Text(state.erreur!, style: AppTypo.style(taille: 14, couleur: c.baisse)),
          ],
        ],
      ),
    );
  }
}

/// « (5 lignes et 5 favoris en gratuit) », vide si l'offre n'a pas de limite.
String _limitesGratuites(Limites l) {
  final parties = [
    if (l.positions != null) '${l.positions} lignes',
    if (l.favoris != null) '${l.favoris} favoris',
  ];
  return parties.isEmpty ? '' : ' (${parties.join(' et ')} en gratuit)';
}
