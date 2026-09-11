569+# Mise en place d'un merge automatique à 3h00

Ce plan vise à automatiser la fusion de la branche `master` vers la branche `main` chaque jour à 3h00 UTC. Cela permettra de synchroniser les mises à jour (notamment les statistiques WakaTime générées à 2h00) vers la branche de production `main`.

## User Review Required

> [!IMPORTANT]
> La fusion se fera de `master` vers `main`. Assurez-vous que `master` est bien votre branche d'intégration/développement comme suggéré par la configuration actuelle (HEAD branch).
> La fusion ne sera effectuée que si les tests (`flutter test`) et l'analyse statique (`flutter analyze`) réussissent sur `master`.

## Proposed Changes

### GitHub Workflows

#### [NEW] [auto_merge.yml](file:///C:/Users/soufi/StudioProjects/portefolio/.github/workflows/auto_merge.yml)
Création d'un nouveau workflow GitHub Actions pour gérer la fusion programmée.

## Verification Plan

### Automated Tests
- Le workflow lui-même exécutera `flutter analyze` et `flutter test`.
- On pourra déclencher le workflow manuellement via l'onglet "Actions" pour vérifier son bon fonctionnement immédiat.

### Manual Verification
- Vérifier dans l'onglet "Actions" de GitHub que le job s'est bien exécuté à 3h00 UTC.
- Vérifier que la branche `main` contient bien les derniers commits de `master` (y compris le commit "Update WakaTime stats").
