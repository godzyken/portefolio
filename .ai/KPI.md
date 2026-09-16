# STRATÉGIE DE PERFORMANCE DIGITALE — CADRE GÉNÉRIQUE (SEO, CONVERSION, PERF, TRACKING)

Ce document définit les standards de qualité et d'optimisation appliqués à tous les projets web et mobiles du portfolio **Godzyken**.

## OBJECTIF GLOBAL
Transformer chaque application ou site en un outil de démonstration de ROI et d'efficacité opérationnelle.

1. **Trafic** : Acquisition organique et payante qualifiée.
2. **Engagement** : Interaction réelle et mémorable.
3. **Conversion** : Transformation des visites en leads ou clients.
4. **Performance** : Excellence technique (Core Web Vitals, Vitesse).

---

# 1. AUDIT SYSTÉMATIQUE (PRÉ-MODIFICATION)
Pour chaque projet sous analyse :
- **Architecture** : Identifier le framework (Flutter, React, PHP) et le mode de rendu (SSR, CSR, SPA).
- **SEO** : Analyser les métadonnées, le sitemap, et la structure sémantique (H1-H3).
- **Conversion** : Évaluer l'efficacité des CTA et la friction des formulaires.
- **Tracking** : Identifier les outils en place (GA4, GTM, Pixel).

---

# 2. SEO TECHNIQUE & LOCAL
*Objectif : Rendre le projet "Google-Friendly" sans sacrifier l'UX.*

- **Siloing sémantique** : Créer des pages de services distinctes avec un contenu rédactionnel riche (300+ mots).
- **Optimisation On-Page** : Title unique, meta description incitative, balises ALT sur chaque image.
- **Données structurées** : Implémenter JSON-LD (Service, LocalBusiness, Project).
- **Localisation** : Cibler précisément les zones d'intervention réelles (ex: Tarn-et-Garonne pour les projets locaux).

---

# 3. PSYCHOLOGIE DE CONVERSION (CRO)
La page doit répondre instantanément à :
- **QUI ?** (L'identité du projet/entreprise).
- **QUOI ?** (La proposition de valeur unique).
- **OÙ ?** (La zone géographique ou le marché cible).
- **ACTION ?** (Ce que l'utilisateur doit faire maintenant).

---

# 4. TRACKING & FUNNEL DE CONVERSION
*Règle d'or : Mesurer ce qui compte.*

### Événements Standards à implémenter :
- `page_view` / `session_start`
- `cta_click` (spécifier lequel : Devis, Appel, Inscription)
- `form_start` / `form_submit` / `form_error`
- `scroll_depth` (25%, 50%, 90%)
- `demo_launch` (clic sur un bouton de démonstration interactive)

### Funnel Type :
`VISITE` → `ENGAGEMENT` → `INTENTION (CLIC CTA)` → `LEAD (FORMULAIRE)` → `CONVERSION (CLIENT)`

---

# 5. PERFORMANCE & CORE WEB VITALS
Ne jamais dégrader la vitesse pour le design.
- **Images** : Compression WebP/AVIF, Lazy Loading, tailles adaptées au viewport.
- **Code** : Tree-shaking, minification, réduction des scripts tiers bloquants.
- **Mobile-First** : Test systématique sur smartphone avec connexion 4G instable.

---

# 6. ÉTHIQUE DES DONNÉES (RGPD & STATS)
- **Transparence** : Toujours indiquer si une donnée est RÉELLE, CALCULÉE ou ESTIMÉE.
- **Zéro triche** : Si aucune donnée n'est disponible, afficher "En attente de collecte".
- **RGPD** : Collecte minimale, politique de confidentialité accessible, consentement explicite.

---

# 7. RAPPORT D'IMPACT (Livrable final)
Chaque cycle d'optimisation doit se terminer par un résumé :
1. **État Initial** : Problèmes détectés et KPIs de base.
2. **Modifications** : Liste des fichiers et changements stratégiques.
3. **Résultats Mesurés** : Gains réels après déploiement.
4. **Priorités futures** : Actions à mener pour le cycle suivant.
