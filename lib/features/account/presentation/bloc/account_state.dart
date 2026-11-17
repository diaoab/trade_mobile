import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/preferences.dart';

/// État de l'onglet Compte : réglages et suivi des actions en cours.
class AccountState {
  final Preferences? preferences;
  final bool chargement;
  final String? erreur;

  final bool motDePasseEnCours;
  final String? erreurMotDePasse;

  /// Incrémenté à chaque changement de mot de passe réussi.
  final int motsDePasseChanges;

  final bool compteSupprime;

  final bool profilEnCours;
  final String? erreurProfil;

  /// Compte renvoyé par la dernière modification du profil réussie.
  final User? profilModifie;

  const AccountState({
    this.preferences,
    this.chargement = false,
    this.erreur,
    this.motDePasseEnCours = false,
    this.erreurMotDePasse,
    this.motsDePasseChanges = 0,
    this.compteSupprime = false,
    this.profilEnCours = false,
    this.erreurProfil,
    this.profilModifie,
  });

  AccountState copyWith({
    Preferences? preferences,
    bool? chargement,
    String? erreur,
    bool? motDePasseEnCours,
    String? erreurMotDePasse,
    int? motsDePasseChanges,
    bool? compteSupprime,
    bool? profilEnCours,
    String? erreurProfil,
    User? profilModifie,
  }) =>
      AccountState(
        preferences: preferences ?? this.preferences,
        chargement: chargement ?? this.chargement,
        erreur: erreur,
        motDePasseEnCours: motDePasseEnCours ?? this.motDePasseEnCours,
        erreurMotDePasse: erreurMotDePasse,
        motsDePasseChanges: motsDePasseChanges ?? this.motsDePasseChanges,
        compteSupprime: compteSupprime ?? this.compteSupprime,
        profilEnCours: profilEnCours ?? this.profilEnCours,
        erreurProfil: erreurProfil,
        profilModifie: profilModifie ?? this.profilModifie,
      );
}
