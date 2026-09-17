# Audit et Correction du Pipeline AVIF

Ce plan vise à résoudre les erreurs 404 et les problèmes d'affichage (images noires) des assets AVIF dans le portfolio Flutter Web.

## Analyse des causes racines

1.  **Incohérence de chemins** : Le fichier `logo_godzyken.avif` est référencé sans son dossier parent `/entreprises/` dans certains fichiers (`unified_image_provider.dart`), provoquant des 404 même si le fichier est présent.
2.  **Pipeline CI incomplet** : Le script Python `generate_all_assets_variants.py` utilisé dans la CI GitHub Actions ignore totalement les fichiers `.avif`. Comme le dossier `assets/images` est dans le `.gitignore`, aucune image AVIF n'est déployée sur GitHub Pages.
3.  **Décodage AVIF** : Les images noires peuvent résulter d'une conversion ImageMagick non optimale pour le moteur de rendu CanvasKit/Web de Flutter, ou d'une absence du fichier (affichant un placeholder noir).

## Modifications proposées

### [Component] Core Service & Provider

#### [MODIFY] [unified_image_provider.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/provider/unified_image_provider.dart)
- Correction du chemin du logo : `assets/images/logo_godzyken.avif` -> `assets/images/entreprises/logo_godzyken.avif`.

#### [MODIFY] [unified_image_manager.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/service/unified_image_manager.dart)
- Renforcement de `_normalizePath` pour supprimer les doubles slashs et assurer une cohérence parfaite.

### [Component] Assets Pipeline

#### [MODIFY] [generate_all_assets_variants.py](file:///C:/Users/soufi/StudioProjects/portefolio/generate_all_assets_variants.py)
- Ajout du support des fichiers `.avif` dans `COPY_ONLY_EXTS` pour garantir leur inclusion dans le build final.
- *Note : Le redimensionnement AVIF n'est pas ajouté au script Python pour éviter de nouvelles dépendances lourdes (pillow-avif-plugin) dans la CI, car le script PowerShell local gère déjà la génération des variantes.*

### [Component] CI/CD

#### [MODIFY] [deploy.yml](file:///C:/Users/soufi/StudioProjects/portefolio/.github/workflows/deploy.yml)
- Ajout d'une étape de vérification des fichiers AVIF générés avant le build Flutter.

## Plan de vérification

### Tests automatisés
- `flutter analyze` pour vérifier l'absence de régressions.
- Vérification manuelle de la présence des fichiers dans `build/web/assets/assets/images/` après un build local.

### Vérification Manuelle
1. Lancer `flutter build web --base-href="/portefolio/"`.
2. Vérifier que `build/web/assets/assets/images/entreprises/logo_godzyken.avif` existe.
3. Déployer et vérifier que le logo s'affiche correctement au splash screen.
