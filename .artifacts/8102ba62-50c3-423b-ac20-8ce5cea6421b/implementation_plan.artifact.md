# Correction des Edge Functions (CORS + EmailJS Security)

Ce plan vise à résoudre les erreurs CORS, d'autorisation et les restrictions de sécurité "Strict Mode" d'EmailJS.

## User Review Required

> [!IMPORTANT]
> Vous **devez** récupérer votre **Private Key** EmailJS (Account > API Keys > Private Key) et l'ajouter aux secrets Supabase.

## Proposed Changes

### [Supabase Edge Functions]

#### [MODIFY] [send-recovery/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Ajout de `accessToken` (Private Key) dans la requête POST vers EmailJS.
- Récupération de `EMAILJS_PRIVATE_KEY` depuis l'environnement Deno.

#### [MODIFY] [insert-portfolio-lead/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/insert-portfolio-lead/index.ts)
- Utilisation de `TURNSTILE_SECRET_KEY` pour la validation serveur.

## Configuration des Secrets Supabase

Exécutez ces commandes pour configurer vos clés privées sur le serveur :

```bash
supabase secrets set EMAILJS_PRIVATE_KEY=votre_cle_privee_emailjs
supabase secrets set TURNSTILE_SECRET_KEY=votre_cle_secrete_cloudflare
```

## Déploiement

```bash
supabase functions deploy send-recovery --no-verify-jwt
supabase functions deploy insert-portfolio-lead --no-verify-jwt
```

## Verification Plan

### Manual Verification
- Ouvrir le portfolio sur le Web.
- Tenter une récupération de mot de passe.
- Vérifier dans l'inspecteur réseau que la requête `OPTIONS` renvoie un code `200` et que la requête `POST` est autorisée.
