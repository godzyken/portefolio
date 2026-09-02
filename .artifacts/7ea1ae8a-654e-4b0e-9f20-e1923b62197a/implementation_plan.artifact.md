# Implementation Plan - Template Setup & Experience Analytics Integration

This plan covers the initial setup of the `godzyken-flutter-ai-template` and the subsequent integration of the experience background (Flutter/Dart & Native) with charts.

## User Review Required

> [!IMPORTANT]
> The template setup will add several hidden directories (`.ai`, `.mcp`, `.agents`) and an `AGENTS.md` file to your project root. These are used to guide AI agents (like me) in maintaining your project.

## Proposed Changes

### [Template Setup]

#### [NEW] [.ai/PROJECT.md](file:///C:/Users/soufi/StudioProjects/portefolio/.ai/PROJECT.md)
#### [NEW] [.ai/ARCHITECTURE.md](file:///C:/Users/soufi/StudioProjects/portefolio/.ai/ARCHITECTURE.md)
#### [NEW] [.ai/ROADMAP.md](file:///C:/Users/soufi/StudioProjects/portefolio/.ai/ROADMAP.md)
#### [NEW] [.ai/DECISIONS.md](file:///C:/Users/soufi/StudioProjects/portefolio/.ai/DECISIONS.md)
#### [NEW] [.ai/TASKS.md](file:///C:/Users/soufi/StudioProjects/portefolio/.ai/TASKS.md)
#### [NEW] [AGENTS.md](file:///C:/Users/soufi/StudioProjects/portefolio/AGENTS.md)
#### [NEW] [.mcp/README.md](file:///C:/Users/soufi/StudioProjects/portefolio/.mcp/README.md)
#### [NEW] [.mcp/dart-flutter-mcp.json](file:///C:/Users/soufi/StudioProjects/portefolio/.mcp/dart-flutter-mcp.json)

### [Experience Analytics]

#### [MODIFY] [about_screens.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/about/views/screens/about_screens.dart)
Add a button or a new section "Analytics & Activity" that displays the experience summary.

#### [NEW] [experience_analytics_widget.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/experience/views/widgets/experience_analytics_widget.dart)
A new widget using `fl_chart` to visualize:
- Time spent on Flutter/Dart vs Native.
- Learning progression over the years (~3.5 years).
- Project distribution (ERP, Web, Mobile).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no regressions.

### Manual Verification
- Verify the presence of template files in the root.
- Check the new "Analytics" section in the Portfolio UI.
