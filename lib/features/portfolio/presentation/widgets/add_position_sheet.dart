import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typo.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_bouton.dart';
import '../../../../core/widgets/app_champ_texte.dart';
import '../../../../core/widgets/etats.dart';
import '../../../../injection_container.dart';
import '../../../market/domain/entities/market_entry.dart';
import '../../../market/domain/usecases/get_structures.dart';
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
  final _prix = TextEditingController();
  late final Future<List<MarketEntry>> _titres;
  late final int _ajoutsAvant;
  String? _symbol;
  DateTime _date = DateTime.now();
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    final etat = context.read<PortfolioBloc>().state;
    _ajoutsAvant = etat is PortfolioLoaded ? etat.ajouts : 0;
    _titres = sl<GetStructures>()().then((r) => r.fold((f) => throw f.errorMessage, (t) => t));
  }

  @override
  void dispose() {
    _quantite.dispose();
    _prix.dispose();
    super.dispose();
  }

  bool get _complet =>
      _symbol != null && (Format.lireNombre(_quantite.text) ?? 0) > 0 && (Format.lireNombre(_prix.text) ?? 0) > 0;

  void _ajouter() {
    setState(() => _envoi = true);
    context.read<PortfolioBloc>().add(PositionAdded(NouvellePosition(
          symbol: _symbol!,
          quantite: Format.lireNombre(_quantite.text)!,
          prixAchat: Format.lireNombre(_prix.text)!,
          dateAchat: _date,
        )));
  }

  Future<void> _choisirDate() async {
    final choix = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (choix != null) setState(() => _date = choix);
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
                        final choisi = titre.symbol == _symbol;
                        return ChoiceChip(
                          label: Text(titre.nom),
                          selected: choisi,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _symbol = titre.symbol),
                          labelStyle: AppTypo.style(taille: 15, graisse: FontWeight.w500, couleur: choisi ? c.surEncre : c.texte),
                          backgroundColor: c.surface,
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
                    Row(children: [
                      Expanded(
                        child: AppChampTexte(
                          libelle: 'Quantité',
                          controller: _quantite,
                          clavier: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppEspace.m),
                      Expanded(
                        child: AppChampTexte(
                          libelle: 'Prix d’achat (FCFA)',
                          controller: _prix,
                          clavier: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppEspace.l),
                    Text('Date d’achat', style: AppTypo.style(taille: 13, graisse: FontWeight.w500, couleur: c.texteMoyen)),
                    const SizedBox(height: AppEspace.s),
                    InkWell(
                      onTap: _choisirDate,
                      borderRadius: BorderRadius.circular(AppRayon.m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRayon.m)),
                        child: Row(children: [
                          Expanded(
                            child: Text(DateFormat('d MMMM y', 'fr_FR').format(_date),
                                style: AppTypo.style(taille: 17, couleur: c.texte)),
                          ),
                          Icon(Icons.event_outlined, size: 18, color: c.texteMoyen),
                        ]),
                      ),
                    ),
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
