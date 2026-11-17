/// Visiteur sans compte (mode démo) : le Marché et l'Analyse lisent alors
/// les routes publiques /demo de l'API. Tenu à jour par l'AuthBloc.
class ModeSession {
  ModeSession._();
  static final ModeSession instance = ModeSession._();

  bool invite = false;
}
