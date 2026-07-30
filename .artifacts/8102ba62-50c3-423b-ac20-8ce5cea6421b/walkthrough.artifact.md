# Résolution des erreurs CORS et d'Autorisation (`send-recovery`)

Les modifications ont été appliquées pour permettre l'appel de la fonction de récupération de mot de passe depuis le Web sans être authentifié.

## Changements effectués

### [send-recovery/index.ts](file:///C:/Users/soufi/StudioProjects/portefolio/supabase/functions/send-recovery/index.ts)
- Ajout de `'Access-Control-Allow-Methods': 'POST, OPTIONS'` dans les en-têtes CORS. Cela indique explicitement aux navigateurs que les méthodes POST et OPTIONS sont autorisées.

## Étapes critiques pour finaliser

> [!CAUTION]
> **Action requise immédiate** : Vous devez redéployer la fonction avec l'option de désactivation du JWT. Si vous ne le faites pas, Supabase continuera de bloquer les requêtes anonymes (401) et les preflights CORS (405).

Exécutez cette commande dans votre terminal :
```bash
supabase functions deploy send-recovery --no-verify-jwt
```

### Pourquoi cette commande ?
- `--no-verify-jwt` : Autorise l'exécution de la fonction sans que l'appelant ne fournisse un token utilisateur valide. C'est indispensable pour une fonction de récupération de mot de passe où l'utilisateur a justement perdu ses accès.
