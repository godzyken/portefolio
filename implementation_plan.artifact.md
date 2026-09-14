# Implementation Plan - Project Analytics V2

Evolution of the project detail page into a "Project Performance Sheet" with real, calculated, and estimated metrics.

## User Review Required

> [!IMPORTANT]
> The implementation will follow a progressive approach. We will first create the generic architecture and models, then instrument `emap_services`, and finally add the UI components.
> No secrets (GA4/GSC keys) will be stored in the frontend. We will use abstractions and mock data for development.

## Proposed Changes

### 1. Data Models

#### [NEW] [analytics_models.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/data/analytics_models.dart)
Define `MetricSourceType`, `MetricDomain`, `ProjectMetric`, `AuditResult`, and `ProjectAnalytics`.

### 2. Services & Providers

#### [NEW] [analytics_repository.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/data/analytics_repository.dart)
Abstract repository to fetch analytics data.

#### [NEW] [analytics_providers.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/providers/analytics_providers.dart)
Riverpod providers for project analytics.

### 3. UI Components

#### [NEW] [analytics_widgets.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/views/widgets/analytics_widgets.dart)
Generic widgets for displaying metrics: `MetricCard`, `AuditScoreCircle`, `SourceBadge`, etc.

#### [NEW] [analytics_section.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/views/widgets/sections/analytics_section.dart)
The main section widget for the detail screen.

### 4. Integration

#### [MODIFY] [section_manager.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/generator/services/section_manager.dart)
Add `_buildAnalyticsSection()` and detection logic.

#### [MODIFY] [project_data.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/projets/data/project_data.dart)
Update `ProjectInfo` if necessary (e.g., to add an `analyticsConfig`).

## Verification Plan

### Automated Tests
- Unit tests for metric parsing and status handling.
- Provider tests for loading and error states.

### Manual Verification
- Verify the new "Analytics" section appears for `emap_services`.
- Check responsiveness on mobile and desktop.
- Verify that "UNAVAILABLE" is shown when no data is present.
- Verify that source badges are correctly displayed.
