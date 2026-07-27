# Walkthrough: Secure Password Recovery Implementation

I have implemented a complete and secure password recovery flow using a Supabase Edge Function combined with EmailJS.

## Changes Made

### 1. Supabase Edge Function (`send-recovery`)
- **Security**: The function uses the `service_role` key (server-side only) to generate a secure recovery link.
- **Branding**: Instead of using Supabase's default (and limited) SMTP, it calls the **EmailJS REST API** to send a branded email.
- **CORS Support**: Added CORS headers to allow calls from your Flutter Web application.

### 2. Flutter Admin Authentication
- **Notifier Update**: Added `sendRecoveryEmail` to `AdminAuthController`. This method invokes the Supabase Edge Function.
- **New State**: Added `AdminAuthRecoverySent` to handle the UI feedback after the email is sent.

### 3. Login UI Improvements
- **"Mot de passe oublié"**: Added a new button to the `AdminLoginScreen`.
- **Validation**: Ensures the email field is filled and valid before attempting recovery.
- **Feedback**: Shows a success SnackBar when the recovery process is initiated.

### 4. Password Reset Page
- **New Screen**: Created `AdminResetPasswordScreen` where users can enter and confirm their new password.
- **Route**: Added the `/admin/reset-password` route to the application's router.
- **Integration**: The recovery link sent by email redirects directly to this page.

## Required Setup (Supabase Dashboard)

> [!IMPORTANT]
> You must set the following secrets in your Supabase project for the Edge Function to work:
> ```bash
> supabase secrets set EMAILJS_SERVICE_ID=your_service_id
> supabase secrets set EMAILJS_RECOVERY_TEMPLATE_ID=your_recovery_template_id
> supabase secrets set EMAILJS_PUBLIC_KEY=your_public_key
> ```
>
> Also, ensure your EmailJS template uses the variable `{{recovery_link}}` for the reset button.

## Verification Results
- [x] Edge Function successfully generates a link.
- [x] Flutter client can invoke the Edge Function.
- [x] UI handles the "Recovery Sent" state with appropriate feedback.
- [x] Redirection to the new Reset Password screen is configured.
