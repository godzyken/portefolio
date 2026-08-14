# Correction du Build CI (GitHub Actions)

Ce plan vise à résoudre les erreurs de compilation sur GitHub Actions en alignant les versions de Flutter et en corrigeant les problèmes de JS Interop.

## Proposed Changes

### [GitHub Workflow]

#### [MODIFY] [deploy.yml](file:///C:/Users/soufi/StudioProjects/portefolio/.github/workflows/deploy.yml)
- Mise à jour de `flutter-version` de `3.41.5` à `3.41.9`.

### [Services Web]

#### [MODIFY] [cv_download_service_web.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/contact/services/cv_download_service_web.dart)
- Utilisation de `.toJS` pour la création du Blob au lieu d'un cast `JSArray`.

## Actions manuelles requises (CRITIQUE)

> [!CAUTION]
> Vous **devez** vous assurer que les nouveaux fichiers sont inclus dans votre prochain commit, car ils manquent actuellement sur GitHub :
> - `lib/features/generator/views/widgets/sections/artifacts_section.dart`
> - `lib/features/projets/data/github_artifacts_service.dart`

```bash
git add .
git commit -m "Fix CI build: update flutter version and JS interop"
git push
```

## Verification Plan

### Manual Verification
- Ouvrir le portfolio sur le Web.
- Tenter une récupération de mot de passe.
- Vérifier dans l'inspecteur réseau que la requête `OPTIONS` renvoie un code `200` et que la requête `POST` est autorisée.
