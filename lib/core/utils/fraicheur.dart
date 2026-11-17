/// Fraîcheur des cours : combien de séances de la BRVM se sont tenues depuis
/// la dernière séance connue.
///
/// La BRVM cote du lundi au vendredi. Les jours fériés ne sont pas connus de
/// l'app : ils comptent comme des séances, ce qui ne fait qu'avancer d'un
/// jour l'apparition du bandeau.
class Fraicheur {
  Fraicheur._();

  /// Au-delà de ce nombre de séances manquantes, les cours sont signalés
  /// comme anciens. 2 laisse passer le cours de la veille consulté avant la
  /// mise à jour du soir, et un jour férié.
  static const int seuilSeances = 2;

  /// Séances (jours ouvrés) écoulées après [date] jusqu'à [maintenant]
  /// inclus ; null si la date est illisible.
  static int? seancesDeRetard(String? date, {DateTime? maintenant}) {
    if (date == null || date.length < 10) return null;
    final debut = DateTime.tryParse(date.substring(0, 10));
    if (debut == null) return null;
    final now = maintenant ?? DateTime.now();
    final fin = DateTime(now.year, now.month, now.day);
    var jour = DateTime(debut.year, debut.month, debut.day);
    var seances = 0;
    while (jour.isBefore(fin)) {
      jour = DateTime(jour.year, jour.month, jour.day + 1);
      if (jour.weekday <= DateTime.friday) seances++;
    }
    return seances;
  }

  /// Vrai si les cours de [date] ont plus de [seuilSeances] séances de retard.
  static bool estAncienne(String? date, {DateTime? maintenant}) {
    final retard = seancesDeRetard(date, maintenant: maintenant);
    return retard != null && retard > seuilSeances;
  }
}
