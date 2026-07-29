# Implementation Plan: Fix Password Recovery Link (Final Sync)

Align the code with the whitelisted URLs in Supabase and handle the "OTP Expired" issue caused by email pre-fetchers.

## User Review Required

> [!IMPORTANT]
> **Supabase Dashboard Actions Required**:
> 1. **Add Redirect URL**: Ensure `https://emap-82.fr/admin/auth/reset` is in your **Redirect URLs** whitelist (Authentication -> URL Configuration).
> 2. **Increase OTP Expiry**: Set "OTP Expiration" to **3600** seconds (Authentication -> Providers -> Email).

## Proposed Changes

### 1. Edge Function (`send-recovery`)
#### [MODIFY] [index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Change the `redirectTo` URL to `https://emap-82.fr/admin/auth/reset` to match the whitelisted pattern and the new Flutter route.

### 2. Flutter Routing
- **[ALREADY DONE]** The route in `router.dart` has been updated to `/admin/auth/reset`.

## Verification Plan

### Manual Verification
1. Deploy the updated Edge Function: `supabase functions deploy send-recovery --no-verify-jwt`.
2. Request a new recovery link from the app.
3. Wait at least 10 seconds before clicking the link in your email.
4. Verify that you land correctly on the reset password page.
