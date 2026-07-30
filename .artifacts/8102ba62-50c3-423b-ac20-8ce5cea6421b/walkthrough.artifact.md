# Correction Globale des Edge Functions (`send-recovery` & `insert-portfolio-lead`)

Toutes les fonctions Edge utilisées par le portfolio ont été corrigées pour supporter les appels depuis le Web et contourner les restrictions de sécurité lors des accès anonymes.

## Changements effectués

### 1. [send-recovery/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Correction des en-têtes CORS (ajout de `OPTIONS` et `POST`).
- Mise à jour de l'URL de redirection vers `https://godzyken.github.io/portefolio/admin/reset-password`.

### 2. [insert-portfolio-lead/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/insert-portfolio-lead/index.ts)
- **CORS** : Ajout de la gestion des requêtes `OPTIONS` et des en-têtes nécessaires pour autoriser les appels depuis le navigateur.
- **Sécurité** : Passage à la clé `SUPABASE_SERVICE_ROLE_KEY` pour permettre l'insertion des leads dans la base de données même si des règles de sécurité (RLS) sont actives sur la table.

---

## Actions de déploiement (Crucial)

> [!CAUTION]
> Vous devez redéployer **les deux fonctions** avec le flag `--no-verify-jwt`. Sans cela, Supabase continuera de bloquer les requêtes avec des erreurs 401 ou 405.

Exécutez ces deux commandes dans votre terminal :

```bash
supabase functions deploy send-recovery --no-verify-jwt
supabase functions deploy insert-portfolio-lead --no-verify-jwt
```

### Pourquoi `--no-verify-jwt` ?
Ce flag est indispensable car ces fonctions sont appelées par des visiteurs qui ne sont pas encore authentifiés (soit parce qu'ils ont perdu leur mot de passe, soit parce qu'ils remplissent un formulaire public). Par défaut, Supabase exige un token utilisateur valide pour chaque appel de fonction.
