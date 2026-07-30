# Correction des Edge Functions Supabase

Ce plan vise à résoudre les erreurs CORS et d'autorisation sur les fonctions `send-recovery` et `insert-portfolio-lead`.

## User Review Required

> [!IMPORTANT]
> Après l'application de ces changements, vous **devez** redéployer les deux fonctions avec le flag `--no-verify-jwt` pour autoriser les appels depuis le site Web.

## Proposed Changes

### [Supabase Edge Functions]

#### [MODIFY] [send-recovery/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Vérification et mise à jour des en-têtes CORS complets.
- Validation de l'URL de redirection vers GitHub Pages.

#### [MODIFY] [insert-portfolio-lead/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/insert-portfolio-lead/index.ts)
- Ajout de la gestion des requêtes `OPTIONS` (CORS).
- Ajout des en-têtes CORS dans toutes les réponses.
- Correction de l'utilisation de `SUPABASE_SERVICE_ROLE_KEY` pour bypasser la sécurité RLS.

## Déploiement

Exécutez ces deux commandes dans votre terminal :

```bash
supabase functions deploy send-recovery --no-verify-jwt
supabase functions deploy insert-portfolio-lead --no-verify-jwt
```

## Verification Plan

### Manual Verification
- Ouvrir le portfolio sur le Web.
- Tenter une récupération de mot de passe.
- Vérifier dans l'inspecteur réseau que la requête `OPTIONS` renvoie un code `200` et que la requête `POST` est autorisée.
