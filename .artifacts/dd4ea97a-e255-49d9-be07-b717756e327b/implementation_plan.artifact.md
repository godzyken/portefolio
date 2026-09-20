# Indexation et Plan de Site (SEO)

Ce plan vise à améliorer le référencement naturel (SEO) du portfolio en indexant correctement les pages, en fournissant un plan de site (sitemap.xml) complet et en optimisant les métadonnées.

## User Review Required

> [!IMPORTANT]
> L'indexation Web pour Flutter nécessite l'utilisation de `UrlStrategy` (déjà probablement en place via GoRouter) et de balises meta dynamiques pour que chaque page ait son propre titre et description dans les résultats de recherche.

## Proposed Changes

### Configuration des Dépendances

#### [MODIFY] [pubspec.yaml](file:///C:/Users/soufi/StudioProjects/portefolio/pubspec.yaml)
- Ajout de la dépendance `seo: ^3.0.1` (ou version compatible) pour la gestion dynamique des balises meta.

---

### Fichiers Statiques Web

#### [MODIFY] [index.html](file:///C:/Users/soufi/StudioProjects/portefolio/web/index.html)
- Mise à jour des balises meta par défaut.
- Ajout de données structurées (JSON-LD) pour le profil professionnel.

#### [MODIFY] [sitemap.xml](file:///C:/Users/soufi/StudioProjects/portefolio/web/sitemap.xml)
- Ajout des routes manquantes : `/project-wizard`, `/projects/pdf`, `/contact`, `/diagnostic`, `/avatar`, `/legal`.
- Mise à jour des priorités et fréquences de changement.

#### [MODIFY] [robots.txt](file:///C:/Users/soufi/StudioProjects/portefolio/web/robots.txt)
- S'assurer que le chemin vers le sitemap est correct et absolu.

---

### Implémentation Flutter (SEO Dynamique)

#### [NEW] [seo_wrapper.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/ui/widgets/seo_wrapper.dart)
- Création d'un widget utilitaire pour envelopper les écrans et injecter les balises `Seo.head`.

#### [MODIFY] Intégration dans les écrans principaux
- [home_screen.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/home/views/screens/home_screen.dart)
- [projects_screen.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/views/screens/projects_screen.dart)
- [experiences_screen.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/experience/views/screens/experiences_screen.dart)
- [contact_screen.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/contact/views/screens/contact_screen.dart)

---

## Verification Plan

### Automated Tests
- `flutter analyze` pour vérifier la validité du code.
- Vérification manuelle de la présence des balises `<meta>` dans l'inspecteur du navigateur après navigation.

### Manual Verification
- Utilisation d'outils de test de sitemap en ligne (après déploiement).
- Vérification du rendu des réseaux sociaux (Open Graph) via des simulateurs.
