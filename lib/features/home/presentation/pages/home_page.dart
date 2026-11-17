import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../injection_container.dart';
import '../../../onboarding/data/prise_en_main_service.dart';
import '../../../onboarding/presentation/pages/prise_en_main_page.dart';
import '../../../account/presentation/bloc/account_bloc.dart';
import '../../../alerts/presentation/bloc/alerts_bloc.dart';
import '../../../account/presentation/bloc/account_event.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../auth/presentation/widgets/connexion_requise.dart';
import '../../../auth/presentation/widgets/compte_invite.dart';
import '../../../../core/widgets/app_ecran.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../market/presentation/bloc/market_bloc.dart';
import '../../../market/presentation/bloc/market_event.dart';
import '../../../market/presentation/pages/market_page.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/bloc/portfolio_event.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';

/// Onglets Marché, Portefeuille, Compte.
///
/// Leurs blocs vivent avec cette page, recréée à chaque connexion : rien du
/// compte précédent ne reste affiché.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<MarketBloc>()),
          BlocProvider(create: (_) => sl<AlertsBloc>()),
          BlocProvider(create: (_) => sl<PortfolioBloc>()),
          BlocProvider(create: (_) => sl<AccountBloc>()),
          BlocProvider(create: (_) => sl<BillingBloc>()),
        ],
        child: const _Onglets(),
      );
}

/// Chaque onglet se recharge quand on l'ouvre : les réglages ou le
/// portefeuille ont pu changer ailleurs.
class _Onglets extends StatefulWidget {
  const _Onglets();

  @override
  State<_Onglets> createState() => _OngletsState();
}

class _OngletsState extends State<_Onglets> {
  int _onglet = 0;

  late final bool _invite = estInvite(context);

  /// En démo, Portefeuille et Compte invitent à créer un compte.
  late final List<Widget> _pages = _invite
      ? const [MarketPage(), _PortefeuilleInvite(), CompteInvite()]
      : const [MarketPage(), PortfolioPage(), AccountPage()];

  @override
  void initState() {
    super.initState();
    _charger(0);
    _priseEnMain();
  }

  /// Premier lancement sur cet appareil : la prise en main, une seule fois.
  Future<void> _priseEnMain() async {
    final service = sl<PriseEnMainService>();
    if (await service.dejaVue() || !mounted) return;
    await ouvrirPriseEnMain(context, onTerminee: service.marquerVue);
  }

  void _charger(int onglet) {
    if (_invite) {
      if (onglet == 0) context.read<MarketBloc>().add(LoadMarket());
      return;
    }
    switch (onglet) {
      case 0:
        context.read<MarketBloc>().add(LoadMarket());
        // Pour la ligne « Votre portefeuille » du résumé du jour.
        context.read<PortfolioBloc>().add(LoadPortfolio());
        context.read<AlertsBloc>().add(LoadAlertes());
      case 1:
        context.read<PortfolioBloc>().add(LoadPortfolio());
      case 2:
        context.read<AccountBloc>().add(LoadPreferences());
        context.read<BillingBloc>().add(LoadOffre());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return Scaffold(
      body: IndexedStack(index: _onglet, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.separateur, width: 0.5))),
        child: NavigationBar(
          selectedIndex: _onglet,
          height: 64,
          onDestinationSelected: (i) {
            setState(() => _onglet = i);
            _charger(i);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Marché'),
            NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Portefeuille'),
            NavigationDestination(
                icon: Icon(Icons.account_circle_outlined), selectedIcon: Icon(Icons.account_circle), label: 'Compte'),
          ],
        ),
      ),
    );
  }
}

class _PortefeuilleInvite extends StatelessWidget {
  const _PortefeuilleInvite();

  @override
  Widget build(BuildContext context) => const AppEcran(
        titre: 'Portefeuille',
        enfants: [
          ConnexionRequise(
            icone: Icons.pie_chart_outline,
            titre: 'Suivez vos placements',
            raison: 'enregistrer vos achats et suivre leur valeur, vos dividendes et votre résultat net de frais',
          ),
        ],
      );
}
