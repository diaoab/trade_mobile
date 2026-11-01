import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/env.dart';
import '../../domain/entities/offre.dart';
import '../../domain/usecases/confirm_payment.dart';
import '../../domain/usecases/get_offre.dart';
import '../../domain/usecases/start_checkout.dart';

abstract class BillingEvent {}

class LoadOffre extends BillingEvent {}

class SouscriptionDemandee extends BillingEvent {}

/// Retour dans l'app après la page de paiement.
class RetourPaiement extends BillingEvent {}

class BillingState {
  final Offre? offre;
  final bool enCours;

  /// Facture en attente de vérification (le client est parti payer).
  final String? jetonEnAttente;

  /// Ouvre la page de paiement : lue une fois par l'écran.
  final String? urlAOuvrir;
  final String? avis;
  final String? erreur;

  /// Statut confirmé : l'écran relit le compte.
  final String? statutConfirme;

  const BillingState({this.offre, this.enCours = false, this.jetonEnAttente, this.urlAOuvrir, this.avis, this.erreur, this.statutConfirme});

  BillingState copyWith({Offre? offre, bool? enCours, String? jetonEnAttente, String? urlAOuvrir, String? avis, String? erreur, String? statutConfirme}) =>
      BillingState(
        offre: offre ?? this.offre,
        enCours: enCours ?? this.enCours,
        jetonEnAttente: jetonEnAttente,
        urlAOuvrir: urlAOuvrir,
        avis: avis,
        erreur: erreur,
        statutConfirme: statutConfirme,
      );
}

/// Paiement de l'offre Pro par PayDunya (Orange Money, Wave, MTN, Moov, carte).
class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetOffre getOffre;
  final StartCheckout startCheckout;
  final ConfirmPayment confirmPayment;

  BillingBloc({required this.getOffre, required this.startCheckout, required this.confirmPayment}) : super(const BillingState()) {
    on<LoadOffre>((event, emit) async {
      final result = await getOffre();
      result.fold((f) => emit(state.copyWith(erreur: f.errorMessage)), (o) => emit(state.copyWith(offre: o)));
    });
    on<SouscriptionDemandee>(_onSouscription);
    on<RetourPaiement>(_onRetour);
  }

  Future<void> _onSouscription(SouscriptionDemandee event, Emitter<BillingState> emit) async {
    emit(state.copyWith(enCours: true));
    final result = await startCheckout(Env.retourPaiement);
    result.fold(
      (f) => emit(state.copyWith(enCours: false, erreur: f.errorMessage)),
      (facture) => emit(state.copyWith(enCours: true, jetonEnAttente: facture.jeton, urlAOuvrir: facture.urlPaiement)),
    );
  }

  Future<void> _onRetour(RetourPaiement event, Emitter<BillingState> emit) async {
    final jeton = state.jetonEnAttente;
    if (jeton == null) return;
    emit(state.copyWith(enCours: true, jetonEnAttente: jeton));
    final result = await confirmPayment(jeton);
    result.fold(
      (f) => emit(state.copyWith(enCours: false, erreur: f.errorMessage)),
      (statut) => emit(state.copyWith(
        enCours: false,
        statutConfirme: statut,
        // Paiement pas encore validé : on garde la facture pour revérifier au prochain retour.
        jetonEnAttente: statut == 'pending' ? jeton : null,
        avis: switch (statut) {
          'completed' => 'Paiement reçu : ton offre Pro est active.',
          'pending' => 'Paiement en attente de validation. Reviens dans quelques instants.',
          _ => 'Paiement non finalisé.',
        },
      )),
    );
  }
}
