import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/fraicheur.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../injection_container.dart';
import '../../../market/domain/entities/market_entry.dart';
import '../../../market/domain/usecases/get_market.dart';
import '../../domain/entities/portfolio.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import '../bloc/portfolio_state.dart';

/// Ouvre le formulaire d'ajout d'une position en feuille modale.
Future<void> ouvrirAjoutPosition(BuildContext context) {
  final bloc = context.read<PortfolioBloc>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.couleurs.fond,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRayon.xl))),
    builder: (_) => BlocProvider.value(value: bloc, child: const _AjoutPosition()),
  );
}

class _AjoutPosition extends StatefulWidget {
  const _AjoutPosition();

  @override
  State<_AjoutPosition> createState() => _AjoutPositionState();
}

class _AjoutPositionState extends State<_AjoutPosition> {
  final _quantite = TextEditingController();
  late final Future<List<MarketEntry>> _titres;
  late final int _ajoutsAvant;
  MarketEntry? _titre;
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    final etat = context.read<PortfolioBloc>().state;
    _ajoutsAvant = etat is PortfolioLoaded ? etat.ajouts : 0;
    _titres = sl<GetMarket>()().then((r) => r.fold((f) => throw f.errorMessage, (t) => t));
  }

  @override
  void dispose() {
    _quantite.dispose();
    super.dispose();
  }

  double get _nombre => Format.lireNombre(_quantite.text) ?? 0;

  bool get _complet => _titre != null && _nombre > 0;

  /// Achat au cours actuel, date du jour : ni le prix ni la date ne se
  /// saisissent (le serveur les fixe).
  void _ajouter() {
    setState(() => _envoi = true);
    context.read<PortfolioBloc>().add(PositionAdded(NouvellePosition(symbol: _titre!.symbol, quantite: _nombre)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return BlocListener<PortfolioBloc, PortfolioState>(
      listener: (context, state) {
        if (state is! PortfolioLoaded) return;
        if (state.ajouts > _ajoutsAvant) {
          Navigator.of(context).pop();
        } else if (state.erreurAction != null) {
          setState(() => _envoi = false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: AppEspace.xl, bottom: AppEspace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
                child: Row(children: [
                  Expanded(
                    child: Text('Nouvelle position',
                        style: AppTypo.style(taille: 22, graisse: FontWeight.w700, couleur: c.texte)),
                  ),
                  AppLien(libelle: 'Annuler', couleur: c.texteMoyen, onPressed: () => Navigator.of(context).pop()),
                ]),
              ),
              const SizedBox(height: AppEspace.l),
              FutureBuilder<List<MarketEntry>>(
                future: _titres,
                builder: (context, snap) {
                  if (snap.hasError) return MessageErreur('${snap.error}');
                  if (!snap.hasData) return const Padding(padding: EdgeInsets.all(AppEspace.l), child: Center(child: CircularProgressIndicator.adaptive()));
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppEspace.gouttiere),
                      itemCount: snap.data!.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppEspace.s),
                      itemBuilder: (context, i) {
                        final titre = snap.data![i];
                        final choisi = titre.symbol == _titre?.symbol;
                        return ChoiceChip(
                          label: Text(titre.nom),
                          selected: choisi,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _titre = titre),
                          labelStyle: AppTypo.style(taille: 15, graisse: FontWeight.w500, couleur: choisi ? c.surEncre : c.texte),
                          backgroundColor: c.champ,
                          selectedColor: c.encre,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRayon.m)),
                        );
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.l, AppEspace.gouttiere, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppChampTexte(
                      libelle: 'Quantité',
                      controller: _quantite,
                      clavier: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppEspace.l),
                    _CoursFixe(titre: _titre, quantite: _nombre),
                  ],
                ),
              ),
              BlocBuilder<PortfolioBloc, PortfolioState>(
                builder: (context, state) =>
                    MessageErreur(state is PortfolioLoaded && _envoi == false ? state.erreurAction : null),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppEspace.gouttiere, AppEspace.l, AppEspace.gouttiere, 0),
                child: AppBouton(libelle: 'Ajouter au portefeuille', enChargement: _envoi, onPressed: _complet ? _ajouter : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cours et date de l'achat, en lecture seule : on achète au cours actuel,
/// aujourd'hui.
class _CoursFixe extends StatelessWidget {
  final MarketEntry? titre;
  final double quantite;
  const _CoursFixe({required this.titre, required this.quantite});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final t = titre;
    Widget ligne(String libelle, String valeur, {bool fort = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(libelle, style: AppTypo.style(taille: 15, couleur: c.texteMoyen)),
            const SizedBox(width: AppEspace.m),
            Expanded(
              child: Text(valeur,
                  textAlign: TextAlign.right,
                  style: AppTypo.style(
                      taille: fort ? 17 : 15, graisse: fort ? FontWeight.w700 : FontWeight.w600, couleur: c.texte, tabulaire: true)),
            ),
          ]),
        );
    final ancien = t != null && Fraicheur.estAncienne(t.date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: c.champ, borderRadius: BorderRadius.circular(AppRayon.m)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ligne('Cours actuel', t == null ? '—' : '${Format.nombre(t.cours)} FCFA'),
          ligne('Date d’achat', 'Aujourd’hui, ${DateFormat('d MMM y', 'fr_FR').format(DateTime.now())}'),
          if (t != null && quantite > 0) ligne('Montant (hors frais)', '${Format.nombre(t.cours * quantite)} FCFA', fort: true),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.lock_outline, size: 14, color: c.texteFaible),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ancien
                    ? 'Dernier cours connu : ${Format.date(t.date)}. Le cours du jour sera cherché à l’achat ; '
                        'sans lui, l’achat sera refusé.'
                    : 'L’achat se fait au cours actuel et à la date du jour.',
                style: AppTypo.style(taille: 12, couleur: ancien ? c.prudence : c.texteFaible),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
