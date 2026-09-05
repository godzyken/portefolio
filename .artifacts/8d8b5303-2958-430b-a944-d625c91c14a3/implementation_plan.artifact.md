# Amélioration de la visibilité des images et ajout du Zoom

Ce plan vise à résoudre le problème des images floues ou illisibles dans la section Projets en ajoutant une fonctionnalité de visualisation plein écran avec zoom interactif.

## User Review Required

> [!IMPORTANT]
> L'ajout d'une interaction au clic sur les images des cartes pourrait entrer en conflit avec le clic sur la carte elle-même. Je propose de prioriser l'ouverture du projet sur le clic de la carte, mais d'ajouter une icône de zoom ou de rendre l'image cliquable spécifiquement pour le plein écran.

## Proposed Changes

### [Core UI]

#### [NEW] [image_viewer.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/ui/widgets/image_viewer.dart)
- Création d'un widget `FullScreenImageViewer` utilisant `InteractiveViewer`.
- Support du zoom par pincement et double-tap.
- Design immersif avec Glassmorphism pour les contrôles (fermer, télécharger).

#### [MODIFY] [smart_image.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/ui/widgets/smart_image.dart)
- Ajout d'une option `enableFullScreenOnTap`.
- Intégration transparente de l'ouverture du viewer.

### [Projets Feature]

#### [MODIFY] [modern_project_card.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/views/widgets/modern_project_card.dart)
- Activation du zoom sur l'image de la carte.
- Ajustement du `BoxFit` pour éviter le flou excessif sur les petits formats si nécessaire.

#### [MODIFY] [project_theatre_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/views/widgets/sections/project_theatre_section.dart)
- Activation du zoom sur les images de mise en scène (Vision, Forge, Impact).

## Verification Plan

### Manual Verification
- Ouvrir un projet dans le portfolio.
- Cliquer sur une image pour l'agrandir.
- Vérifier le zoom (pincement ou molette).
- Vérifier que l'image est nette en plein écran (si la source le permet).
