import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../auth/presentation/widgets/connexion_requise.dart';
import '../bloc/favorites_bloc.dart';

/// Étoile pour suivre un titre (écran Analyse).
class BoutonFavori extends StatelessWidget {
  final String symbol;
  final String nom;
  const BoutonFavori({super.key, required this.symbol, required this.nom});

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      // Refus de l'API (limite de l'offre gratuite…) : message.
      listenWhen: (a, b) => b.erreur != null && a.erreur != b.erreur,
      listener: (context, state) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.erreur!))),
      buildWhen: (a, b) => a.contient(symbol) != b.contient(symbol),
      builder: (context, state) {
        final suivi = state.contient(symbol);
        return IconButton(
          onPressed: () => estInvite(context)
              ? demanderConnexion(context, raison: 'suivre $nom en favori et recevoir ses alertes')
              : context.read<FavoritesBloc>().add(BasculerFavori(symbol)),
          tooltip: suivi ? 'Retirer $nom des favoris' : 'Ajouter $nom aux favoris',
          icon: Icon(suivi ? Icons.star_rounded : Icons.star_outline_rounded,
              color: suivi ? c.prudence : c.texte, size: 28),
        );
      },
    );
  }
}
