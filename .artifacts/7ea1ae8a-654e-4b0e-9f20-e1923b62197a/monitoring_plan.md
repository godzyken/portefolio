### RÔLE ET CONTEXTE
Tu es un expert Flutter / Dart, spécialisé dans les architectures modulaires, Supabase et la visualisation de données Web (Data Visualization).

Je développe un écosystème d'applications Flutter comprenant :
- Mon Portfolio (Application maître / Tour de contrôle)
- Apps clientes / Projets : emap_services, bat_track, egote_services, compta4me.

### OBJECTIF
Faire évoluer mon Portfolio pour qu'il devienne une "Tour de Contrôle" en temps réel sans casser le code existant.
Le portfolio doit afficher le workflow, le cadrage (CCTP, SEO, KPIs) et des statistiques en direct pour convertir deux cibles :
1. Recruteurs / ESN : Métriques de workflow, temps de traitement, compétences acquises, temps passé par techno.
2. Artisans / Prospects : Statistiques d'usage en live sur des projets similaires (ex: volumes sur Bat_Track, Uptime, devis générés).

### PRÉREQUIS & EXISTANT (NE PAS CASSER)
1. **WakaTime API / GitHub Actions** : J'ai déjà une intégration WakaTime fonctionnelle via GitHub Actions pour mesurer le temps passé et les technologies utilisées.
-> **RÈGLE OBLIGATOIRE** : Conserver et réutiliser cette logique / cette source de données pour la partie "Temps & Technos". L'adapter ou l'étendre sans réécrire l'existant.
2. **Stack Technique** : Flutter Web, Riverpod pour le State Management, Supabase pour le Backend / Realtime, et `fl_chart` pour les graphiques.

---

### INSTRUCTIONS ET CODE À GÉNÉRER

#### 1. Architecture des Données & Riverpod
- Crée une structure propre de providers Riverpod séparant :
- `wakatimeProvider` : Récupération des données d'heures/technos issues du flux WakaTime existant.
- `liveAnalyticsStreamProvider` : Stream Supabase Realtime écoutant la table `app_analytics` pour remonter les KPIs d'utilisation des apps clientes (ex: Bat_Track, EMAP).

#### 2. Composant Graphique avec `fl_chart`
Génère un widget Flutter Web réutilisable `ActivityMetricsChart` basé sur la bibliothèque `fl_chart` :
- Supporte l'affichage de deux vues via un `SegmentedButton` ou un Switch :
- **Vue "Recruteur"** : Graphique en barres / lignes comparant le Temps Passé (data WakaTime) vs KPIs de Qualité/Workflow (ex: tests validés, builds CI/CD).
- **Vue "Artisan"** : Graphique d'activité / volume d'utilisation d'une application cible en live (data Supabase Stream).
- Le graphique doit être responsive, fluide, avec des tooltips clairs au survol.

#### 3. Sécurité & Modélisation (Supabase RLS)
- Fournis le script SQL d'une table `app_analytics` dans Supabase.
- Incluis les politiques Row Level Security (RLS) pour autoriser la lecture seule (`SELECT`) en anonyme pour le portfolio, et l'insertion (`INSERT`) restreinte pour les apps clientes.
- Assure-toi qu'aucune donnée personnelle (PII) ne soit stockée, uniquement des données agrégées.

#### 4. Intégration / Exemple d'Appel
- Montre un exemple d'intégration propre de ce widget dans une section de page Portfolio, avec gestion des états d'attente (`AsyncLoading`) et d'erreur (`AsyncError`).

Génère du code Dart propre, typé, commenté et structuré selon les meilleures pratiques Flutter/Riverpod.
