# Plan d'Optimisation de la Performance Web (PageSpeed Insights)

Ce plan vise à corriger les goulots d'étranglement identifiés dans le rapport PageSpeed Insights pour la version mobile, en se concentrant sur le fichier [index.html](file:///C:/Users/soufi/StudioProjects/portefolio/web/index.html).

## Problèmes identifiés

### 1. Chargement synchrone d'un modèle 3D volumineux
Le fichier [index.html](file:///C:/Users/soufi/StudioProjects/portefolio/web/index.html) contient une balise `<model-viewer>` directement dans le `<body>`. Cette balise télécharge immédiatement le fichier `perso_samurail.glb` (plusieurs Mo) au chargement de la page, avant même que Flutter ne s'initialise. Cela dégrade fortement le **LCP (Largest Contentful Paint)** et le **Speed Index** sur mobile.
Ce modèle est déjà géré dynamiquement par le widget `CharacterViewer` dans l'application Flutter via le package `model_viewer_plus`, rendant la balise HTML en dur redondante et nuisible à la performance initiale.

### 2. Téléchargement forcé de CanvasKit sur mobile
La configuration Flutter actuelle force le moteur de rendu `canvaskit`. Sur mobile, cela impose le téléchargement de `canvaskit.wasm` (~3-5 Mo) au démarrage, augmentant le **Total Blocking Time (TBT)**. Passer en mode `auto` permet d'utiliser le moteur HTML (plus léger) sur mobile tout en conservant `canvaskit` sur desktop.

## Changements proposés

### [Web Optimization]

#### [MODIFY] [index.html](file:///C:/Users/soufi/StudioProjects/portefolio/web/index.html)
- Supprimer la balise `<model-viewer>` redondante dans le `<body>`.
- Mettre à jour `window._flutter.buildConfig.renderer` de `"canvaskit"` à `"auto"`.
- S'assurer que les balises de préchargement ou de script ne bloquent pas inutilement le rendu initial.

## Plan de Vérification

### Tests automatisés
- `flutter analyze` pour vérifier qu'aucun changement n'impacte la compilation.
- `flutter build web --release` pour valider la génération des fichiers de production.

### Vérification Manuelle
- Inspection du DOM dans Chrome DevTools pour confirmer l'absence du téléchargement prématuré du modèle 3D.
- Analyse du réseau pour vérifier le chargement conditionnel de `canvaskit.wasm` (uniquement sur Desktop).
- Nouvelle analyse PageSpeed Insights après déploiement pour mesurer le gain de performance.
