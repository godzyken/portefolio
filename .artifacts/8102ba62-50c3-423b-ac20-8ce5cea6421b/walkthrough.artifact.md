# Correction Globale des Edge Functions (CORS + EmailJS + Turnstile)

Toutes les fonctions Edge utilisées par le portfolio ont été corrigées pour supporter les appels depuis le Web, contourner les restrictions de sécurité "Strict Mode" d'EmailJS, et valider correctement le captcha Cloudflare.

## Changements effectués

### 1. [send-recovery/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- **CORS** : Correction des en-têtes (ajout de `OPTIONS` et `POST`).
- **Sécurité EmailJS** : Ajout du paramètre `accessToken` (Private Key). Cela permet de fonctionner même si le "Strict Mode" est activé dans EmailJS.
- **Redirection** : Lien mis à jour vers GitHub Pages.

### 2. [insert-portfolio-lead/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/insert-portfolio-lead/index.ts)
- **CORS** : Ajout de la gestion des requêtes `OPTIONS`.
- **Sécurité** : Passage à la clé `SUPABASE_SERVICE_ROLE_KEY` pour bypasser le RLS.
- **Turnstile** : Passage à `TURNSTILE_SECRET_KEY` pour la validation serveur du captcha.

---

## Actions Requises (Crucial)

### 1. Configuration des secrets sur Supabase
Exécutez ces commandes pour que les fonctions puissent accéder à vos clés privées :

```bash
supabase secrets set EMAILJS_PRIVATE_KEY=votre_cle_privee_emailjs
supabase secrets set TURNSTILE_SECRET_KEY=votre_cle_secrete_cloudflare
```

### 2. Déploiement des fonctions
Redéployez pour appliquer les changements :

```bash
supabase functions deploy send-recovery --no-verify-jwt
supabase functions deploy insert-portfolio-lead --no-verify-jwt
```
