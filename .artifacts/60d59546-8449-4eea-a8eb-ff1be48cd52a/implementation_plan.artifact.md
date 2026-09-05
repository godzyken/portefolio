# Remplacement des statistiques codées en dur par des métriques dynamiques (WakaTime & Supabase)

Ce plan vise à transformer les sections de statistiques des projets pour qu'elles affichent des données en temps réel issues de WakaTime (pour le développement) et Supabase (pour l'usage live), remplaçant ainsi les graphiques statiques actuels.

## User Review Required

> [!IMPORTANT]
> Je prévois de remplacer les graphiques statiques dans les sections **Résultats** et **Théâtre (Impact)** par le nouveau widget `ActivityMetricsChart`.
> Dois-je supprimer définitivement les anciennes usines de graphiques (`ChartDataFactory`) ou les conserver en fallback pour les projets n'ayant pas de données live ?

## Proposed Changes

### Core & Data

#### [NEW] [supabase_analytics_setup.sql](file:///C:/Users/soufi/StudioProjects/portefolio/.artifacts/60d59546-8449-4eea-a8eb-ff1be48cd52a/supabase_analytics_setup.sql)
Script SQL pour la table `app_analytics` et les politiques RLS.

#### [NEW] [analytics_provider.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/provider/analytics_provider.dart)
Ajout des providers Riverpod pour Supabase Realtime Analytics.

---

### Features / Experience & Projects

#### [NEW] [activity_metrics_chart.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/experience/views/widgets/activity_metrics_chart.dart)
Widget réutilisable `ActivityMetricsChart` avec deux vues : "Recruteur" (WakaTime vs Qualité) et "Artisan" (Live Volume).

#### [MODIFY] [result_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/views/widgets/sections/result_section.dart)
Intégration du `ActivityMetricsChart` à la place des graphiques statiques dans la section Résultats.

#### [MODIFY] [project_theatre_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/views/widgets/sections/project_theatre_section.dart)
Mise à jour de la scène `_ImpactScene` pour inclure les métriques dynamiques.

## Verification Plan

### Automated Tests
- `flutter analyze` pour vérifier la compilation.
- `flutter test` pour s'assurer qu'aucune régression n'est introduite dans les providers.

### Manual Verification
- Vérifier le basculement entre les vues "Recruteur" et "Artisan" dans le portfolio Web.
- Vérifier que les données WakaTime sont bien récupérées pour les projets correspondants.
- Simuler des insertions dans Supabase pour voir le graphique "Artisan" se mettre à jour en temps réel.
