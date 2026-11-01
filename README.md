# Financial AI Advisor — app mobile

App Flutter (Android et iOS) branchée sur l'API [trade_back](../trade_back) :
marché de la BRVM, analyse d'un titre (graphique, signal du moteur, modèle,
assistant), portefeuille, compte et offre Pro (PayDunya).

Même architecture que `sign-mobile` : `core/` pour le socle commun,
`features/` par domaine, chacun découpé en `data` / `domain` / `presentation`
(datasource Dio → repository → use case → bloc → page), injection par `get_it`,
erreurs remontées en `Either<Failure, T>` (dartz).

**Ce n'est pas un outil de conseil financier.**

## Structure

```
lib/
  main.dart                 Démarrage, thème, redirection selon la session
  injection_container.dart  Enregistrement des dépendances (get_it)
  core/
    config/env.dart         Adresse de l'API et chemins des routes
    constants/              Signaux du moteur, seuils, avertissement
    errors/                 ServerException, Failure
    network/                Intercepteur (jeton, renouvellement), appelApi()
    routes/app_router.dart  Routes nommées
    services/               Jetons (trousseau / Keystore), bus de déconnexion
    theme/                  Couleurs (clair / sombre), espacements, typo
    utils/format.dart       Nombres, pourcentages et dates en français
    widgets/                Écran, sections, boutons, champs, pastilles…
  features/
    auth/                   Connexion, inscription, reprise de session
    market/                 Liste des titres et répartition des signaux
    analysis/               Analyse d'un titre, graphique, assistant
    portfolio/              Positions, valorisation, ajout / suppression
    account/                Réglages d'analyse, mot de passe, suppression
    billing/                Offre Pro, paiement PayDunya
    home/                   Onglets Marché / Portefeuille / Compte
    splash/                 Écran de démarrage
test/                       Tests unitaires et tests des blocs
```

## Démarrage

L'API doit tourner à côté (`../trade_back`) :

```bash
python -m uvicorn api.main:app --reload
```

Puis :

```bash
flutter pub get
flutter run
```

En développement, l'app appelle `http://localhost:8000` (simulateur iOS) ou
`http://10.0.2.2:8000` (émulateur Android). Compte de démonstration : créé
par `python -m api.scripts.seed_dev` dans `trade_back`.

> **Projet sur le Bureau synchronisé par iCloud** : le build iOS peut échouer
> avec « resource fork, Finder information, or similar detritus not allowed ».
> Le Bureau ajoute des attributs étendus aux fichiers générés. Construire depuis
> un dossier non synchronisé, ou désactiver la synchronisation du Bureau.

## Qualité

```bash
flutter analyze
flutter test
```

La même vérification tourne sur GitHub Actions (`.github/workflows/ci.yml`),
avec un build Android et iOS sans signature.

## Production

L'adresse de l'API est fixée au build :

```bash
flutter build appbundle --dart-define=API_BASE_URL=https://api.exemple.com
flutter build ipa --dart-define=API_BASE_URL=https://api.exemple.com
```

- Identifiant : `com.financialaiadvisor.app` (Android et iOS), le même que
  l'ancienne version Expo, pour publier en mise à jour.
- Retour de paiement : schéma `finadvisor://` ; il doit figurer dans
  `APP_REDIRECT_PREFIXES` côté API.
- Icônes : `dart run flutter_launcher_icons` (sources dans `assets/images/`).
