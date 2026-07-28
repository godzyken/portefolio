# Implementation Plan: Scalable Unified Conversion Dashboard

This plan implements a highly scalable tracking and analytics system. It allows you to monitor user interactions and conversions for your Portfolio and **any number of affiliated projects** (starting with EMAP Services) from a single Admin Dashboard.

## User Review Required

> [!IMPORTANT]
> **Supabase Setup**: You must create the following table. It is designed to be generic so that any project (Portfolio, EMAP, or future apps) can send data to it.
> ```sql
> CREATE TABLE portfolio_interactions (
>   id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
>   project_id text NOT NULL,     -- ex: 'portfolio', 'emap_services', 'app_v3'
>   project_name text,            -- Display name for the dashboard
>   action_type text NOT NULL,    -- 'WHATSAPP', 'CALL', 'EMAIL', 'FORM_SUBMIT', 'LINK_CLICK'
>   details jsonb,                -- Flexible context (ex: { "service": "plomberie", "page": "pricing" })
>   created_at timestamptz DEFAULT now()
> );
>
> CREATE INDEX idx_interactions_project_id ON portfolio_interactions(project_id);
> ```

## Proposed Changes

### 1. Scalable Tracking Core
- **[NEW] `lib/core/service/tracking_service.dart`**: A singleton service that can be used anywhere in the app (or copied to other projects).
    - `trackInteraction({required String projectId, required String actionType, Map<String, dynamic>? details})`
- **[NEW] `lib/core/provider/tracking_provider.dart`**: Riverpod provider to inject the service.

### 2. Global Integration (Portfolio)
- **Automatic Project Detection**: The Portfolio will use `project_id: 'portfolio'`.
- **Project-Specific Tracking**: If the user is on the EMAP project page in your portfolio and clicks a link, it will be tracked as `project_id: 'emap_services'`.
- **Listeners**:
    - **Contact Form**: Tracks `WHATSAPP`, `CALL`, `EMAIL`.
    - **Diagnostic/Wizard**: Tracks `FORM_SUBMIT` with success metadata.

### 3. Dynamic Analytics Dashboard
- **[NEW] `lib/features/admin/providers/analytics_provider.dart`**:
    - Uses Supabase `group by project_id` to fetch stats for **all** projects found in the DB.
    - No hardcoded project names; the dashboard will automatically show new columns/cards as you add new projects to your ecosystem.
- **[NEW] `lib/features/admin/views/widgets/analytics_dashboard_view.dart`**:
    - High-level KPI cards (Total Leads, Conversion Rate).
    - Comparative charts (Interactions per Project).
    - Recent activity log.

### 4. Admin UI Update
- **[MODIFY] [AdminDashboardScreen](file:///C:/Users/soufi/StudioProjects/portefolio/lib/features/admin/views/screens/admin_dashboard_screen.dart)**: Add a toggle or TabBar to switch between "Service Management" and "Analytics & Conversions".

## Verification Plan

### Manual Verification
1. Click "WhatsApp" in the Portfolio contact section -> Verify `portfolio` entry in Supabase.
2. Click the external link to "EMAP Services" -> Verify `emap_services` entry in Supabase.
3. Access the Admin Dashboard -> Verify that both projects appear automatically in the Analytics view.
4. Verify that the "Conversion Rate" is calculated correctly for each project.
