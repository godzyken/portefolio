# Correction de la Edge Function `send-recovery`

Le but est de résoudre les erreurs 405 (Method Not Allowed) sur les requêtes OPTIONS et 401 (Unauthorized) lors de l'appel depuis le Web.

## User Review Required

> [!IMPORTANT]
> Après l'application de ces changements, vous **devez** redéployer la fonction avec la commande spécifique fournie ci-dessous pour désactiver la vérification du JWT.

## Proposed Changes

### [Supabase Edge Functions]

#### [MODIFY] [index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Ajout de `Access-Control-Allow-Methods` aux en-têtes CORS.
- Clarification de la réponse aux requêtes `OPTIONS`.

## Déploiement

Exécutez cette commande dans votre terminal à la racine du projet :

```bash
supabase functions deploy send-recovery --no-verify-jwt
```

## Verification Plan

### Manual Verification
- Ouvrir le portfolio sur le Web.
- Tenter une récupération de mot de passe.
- Vérifier dans l'inspecteur réseau que la requête `OPTIONS` renvoie un code `200` et que la requête `POST` est autorisée.
