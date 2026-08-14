# Amélioration Immersive du Portfolio (Projets & Expériences)

Ce plan vise à transformer la présentation des projets et des expériences en utilisant le framework visuel et technique défini par les infographies `FlutterSkills`. L'objectif est de rendre le portfolio plus percutant pour les chasseurs de têtes en privilégiant le visuel et la preuve de compétence technique.

## User Review Required

> [!IMPORTANT]
> - L'analyse des infographies `FlutterSkills` a permis d'identifier 7 piliers de maturité technique (Architecture, State, Testing, Security, Performance, CI/CD, Monitoring).
> - Je propose d'ajouter une section "Analyse de Maturité (IA)" qui synthétise ces points pour chaque projet.
> - La section "En savoir plus" sera transformée pour ne plus être un simple bloc de texte mais une interface immersive.

## Proposed Changes

### [Core/Affichage]

#### [NEW] [tech_maturity_framework.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/affichage/tech_maturity_framework.dart)
- Définition des 7 piliers techniques basés sur les infographies.
- Map d'icones et de couleurs associées.

### [Features/Projets]

#### [MODIFY] [section_manager.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/services/section_manager.dart)
- Ajout d'une détection automatique de la maturité technique basée sur les données du projet (`techDetails`, `tags`, `points`).

#### [MODIFY] [artifacts_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/views/widgets/sections/artifacts_section.dart)
- Refonte visuelle : Style "Glassmorphism" avec flou d'arrière-plan.
- Ajout de cartes de résumé technique au-dessus du contenu Markdown.
- Intégration d'images/icones thématiques issues du framework `FlutterSkills`.
- Priorisation des visuels : si des images sont présentes dans les artefacts, elles seront mises en avant.

### [Features/Generator]

#### [MODIFY] [hero_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/views/widgets/sections/hero_section.dart)
- Intégration de badges de compétences "Expert" basés sur les infographies pour une lecture rapide par les recruteurs.

### [Data]

#### [MODIFY] [projects.json](file:///C:/Users/soufi/StudioProjects/portefolio/assets/data/projects.json)
- Enrichissement des métadonnées pour permettre une analyse de maturité plus fine (ex: mention des types de tests, architecture utilisée).

## Verification Plan

### Manual Verification
- Vérifier que la section "En savoir plus" n'est plus un bloc noir mais une interface riche et aérée.
- Vérifier que les piliers techniques (Performance, Architecture, etc.) sont bien mis en évidence.
- S'assurer que le contenu reste fluide sur mobile.
