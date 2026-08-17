# PROMPT — Avatar conversationnel adaptatif pour portfolio Flutter

Colle ce prompt tel quel dans l'assistant IA d'Android Studio (Gemini). Il est
calibré sur l'architecture réelle du projet `portefolio` — ne pas généraliser
les conventions ci-dessous, elles doivent être respectées à la lettre.

---

## CONTEXTE PROJET

Tu travailles sur `portefolio`, une app Flutter (web + mobile) qui sert de
portfolio interactif pour un développeur Flutter freelance. Stack :

- **State management** : `flutter_riverpod: ^3.0.3` — utiliser exclusivement
  la nouvelle API (`Notifier`, `NotifierProvider`, `AsyncNotifier`,
  `FutureProvider.family`). NE PAS utiliser `StateNotifierProvider` (legacy).
- **Navigation** : `go_router: ^17.0.0`
- **Backend** : `supabase_flutter: ^2.10.4` (leads, auth admin)
- **Fallback email** : `emailjs: ^4.0.0` — pattern déjà en place dans
  `lib/features/project_wizard/services/project_wizard_lead_service.dart`
  et `DiagnosticLeadService` : tenter Supabase, fallback EmailJS si erreur,
  ne jamais perdre un lead.
- **IA existante** : appels OpenAI directs en HTTP (pas de SDK), clé via
  `String.fromEnvironment('OPENAI_API_KEY')` — voir
  `lib/features/projets/data/github_project_ai_analyzer.dart` et
  `lib/features/project_wizard/services/project_wizard_ai_service.dart`
  pour le pattern exact (modèle `gpt-4o-mini`, `response_format: json_object`).
- **Couleurs** : `lib/core/affichage/colors_spec.dart` (`ColorHelpers`) —
  thème cyberpunk/neon : `cyan (0xFF00D9FF)`, `magenta (0xFFFF2D78)`,
  `surface (0xFF0D1117)`, `border (0xFF1E2D40)`, `textSecondary (0xFF8BA3BF)`.
  Toujours réutiliser ces constantes, ne jamais coder des couleurs en dur.
- **Animations** : `flutter_animate: ^4.5.2` déjà utilisé partout
  (`.animate().fadeIn()`, `.slideY()`, `.scale()`) — rester cohérent avec ce
  style d'animation plutôt que d'introduire un autre système.
- **Responsive** : `ResponsiveInfo` / `ref.watch(responsiveInfoProvider)`
  (`lib/core/affichage/screen_size_detector.dart`) pour toute adaptation
  mobile/desktop — ne pas utiwith `MediaQuery` brut.
- **Sécurité formulaires** : `cloudflare_turnstile: ^3.7.2` déjà intégré
  pour le login admin (`lib/core/service/turnstile_service.dart`) —
  réutilisable pour protéger le chat contre l'abus (coût API).

### Briques déjà existantes à réutiliser (NE PAS recréer) :

1. **`TechPillar`** (`lib/core/affichage/tech_maturity_framework.dart`) —
   enum des 8 piliers techniques (Architecture, State Management, Testing,
   Sécurité, Performance, CI/CD, Monitoring, AI & Smart Features), chacun
   avec label, description, icône, couleur, image. `TechMaturityRadar`
   widget associé pour l'affichage.
2. **`GithubArtifactsService`** (`lib/features/projets/data/`) — récupère
   les fichiers `.md` (présentation, vision, workthrough, valuation,
   implementation) depuis `.artefacts/{id}/` sur GitHub. C'est la source de
   vérité "profonde" pour le RAG de l'avatar.
3. **`ProjectTheatreSection`** / **`ExperienceTheatreSection`** — pattern de
   mise en scène narrative en 3 "scènes" avec `AnimatedSwitcher`. L'avatar
   doit s'intégrer À CÔTÉ de ce système, pas le remplacer.
4. **`TrackingService`** / `TrackingAction` enum
   (`lib/core/service/tracking_service.dart`) — actuellement
   `{whatsapp, call, email, formSubmit, linkClick}`. À étendre avec de
   nouveaux événements pour l'avatar (voir Phase 3 ci-dessous).
5. **`DiagnosticLeadService`** (`lib/features/generator/...` ou équivalent)
   — pattern exact de capture de lead à copier pour la conversion qualifiée.

---

## OBJECTIF PRODUIT (vision long terme)

Un avatar anime la présentation du parcours du développeur. Plus le
prospect (recruteur ou client) pose des questions techniques précises,
plus l'avatar entre en profondeur technique — en s'appuyant sur les vraies
données du portfolio (expériences, projets, artefacts `.md`). Le but final
est la **conversion qualifiée** : faire remonter un lead (email/contact)
au bon moment, quand l'engagement démontré justifie qu'on lui propose de
poursuivre l'échange hors-app.

---

## PHASAGE — IMPLÉMENTER DANS CET ORDRE, UNE PHASE = UNE ITÉRATION VALIDÉE

### Phase 1 — Avatar Rive + Chat texte + RAG minimal (MVP)

**But** : un avatar visible et animé (idle / parle / réfléchit), une zone
de chat texte, des réponses IA groundées sur les données réelles du
portfolio (pas d'hallucination).

Tâches :
1. Ajouter `rive: ^0.13.x` (vérifier la dernière version stable sur pub.dev
   avant d'ajouter) au `pubspec.yaml`.
2. Créer `lib/features/avatar/` avec la structure suivante (respecter les
   conventions dossier `data/`, `providers/`, `services/`, `views/` déjà
   utilisées dans `lib/features/projets/` et `lib/features/experience/`) :
   - `data/avatar_message.dart` — modèle de message (role: user/avatar,
     content, timestamp, relatedPillar: TechPillar?)
   - `services/avatar_context_builder.dart` — agrège les données du
     portfolio (experiences_data.json, projects.json, artefacts déjà
     fetchés via `GithubArtifactsService`) en un contexte texte compact
     pour le prompt système de l'IA. Doit tronquer intelligemment pour
     rester sous la limite de tokens raisonnable (~4000 tokens de contexte).
   - `services/avatar_chat_service.dart` — appel OpenAI, MÊME PATTERN que
     `github_project_ai_analyzer.dart` (HTTP direct, pas de SDK,
     `String.fromEnvironment('OPENAI_API_KEY')`). Prompt système qui
     contraint l'IA à ne répondre qu'à partir du contexte fourni (éviter
     l'hallucination sur des compétences non démontrées).
   - `notifiers/avatar_chat_notifier.dart` — `Notifier` (Riverpod 3, pas
     `StateNotifier`) gérant l'historique de conversation.
   - `views/widgets/avatar_display.dart` — le widget Rive, avec au moins
     3 états de state machine : `Idle`, `Talking`, `Thinking`.
   - `views/widgets/avatar_chat_panel.dart` — UI du chat (bulle style
     `NarrativeBubble` existant dans `lib/core/ui/widgets/narrative_bubble.dart`
     à réutiliser/adapter plutôt que recréer un style de bulle différent).
   - `views/screens/avatar_screen.dart` — écran dédié, accessible via une
     nouvelle route go_router (ex: `/avatar`).
3. **Placeholder Rive** : si aucun fichier `.riv` n'est encore designé,
   créer un état de fallback (ex: `Icon` animé pulsant avec `flutter_animate`)
   pour que le code fonctionne sans bloquer sur l'asset graphique — le vrai
   fichier `.riv` sera fourni séparément.
4. Protéger le chat avec `cloudflare_turnstile` (pattern de
   `turnstile_service.dart`) avant le premier envoi de message, pour éviter
   l'abus du quota OpenAI.

**Critère de validation Phase 1** : je peux taper une question technique
("comment gères-tu le state management sur tes projets Flutter ?"),
l'avatar "réfléchit" puis répond avec du contenu réellement issu de mes
données (pas générique), sans coût API incontrôlé possible.

---

### Phase 2 — Profondeur adaptative + Voix

**But** : le niveau de détail des réponses augmente avec l'engagement
démontré sur un pilier technique donné.

Tâches :
1. `notifiers/engagement_notifier.dart` — `Notifier<Map<TechPillar, int>>`
   qui incrémente un score par pilier à chaque question classifiée sur ce
   pilier (classification simple par mots-clés d'abord, embeddings en
   option plus tard).
2. Le `avatar_chat_service.dart` injecte le niveau de profondeur courant
   dans le prompt système : sous 2 questions sur un pilier = réponse
   vulgarisée ; 2-4 = réponse avec détails d'implémentation ; 5+ = réponse
   avec extraits de code / architecture précise, et suggestion explicite
   de consulter l'artefact `.md` correspondant (`implementation.md`,
   `valuation.md`...) via un lien cliquable dans le chat.
3. Ajouter `flutter_tts: ^4.x` (vérifier dernière version stable) pour la
   voix. Synchroniser grossièrement l'état `Talking` de l'avatar Rive sur
   la durée de la synthèse vocale (pas de lip-sync phonème par phonème,
   juste bouche qui "flap" pendant que `flutter_tts` parle).

**Critère de validation Phase 2** : poser 5 questions de suite sur la
sécurité fait progressivement apparaître des réponses plus techniques
(mention de patterns précis du code réel), avec une suggestion de lire
`securite.md` à un moment donné. L'avatar parle à voix haute.

---

### Phase 3 — Conversion qualifiée

**But** : transformer l'engagement démontré en lead exploitable.

Tâches :
1. Étendre `TrackingAction` : ajouter `avatarQuestionAsked`,
   `avatarDepthMilestone`, `avatarLeadQualified`.
2. Définir un seuil de qualification (ex: score cumulé > 8 sur au moins 2
   piliers différents, OU question explicite contenant "tarif",
   "disponibilité", "délai", "recrutement").
3. Au franchissement du seuil, l'avatar propose (dans le chat, pas de popup
   intrusive) : "Je peux t'envoyer un résumé de notre échange + mes
   coordonnées par email, ça t'intéresse ?" → si oui, formulaire minimal
   (nom + email) → service `avatar_lead_service.dart` MÊME PATTERN que
   `DiagnosticLeadService` (insert Supabase table `avatar_leads`, fallback
   EmailJS avec le résumé de conversation en contenu).
4. Schema Supabase à documenter en commentaire dans le service (comme fait
   dans `DiagnosticLeadService`) :
   ```sql
   create table avatar_leads (
     id uuid primary key default gen_random_uuid(),
     name text,
     email text not null,
     conversation_summary text not null,
     pillars_explored text[] not null,
     max_depth_score int not null,
     created_at timestamptz not null default now()
   );
   ```

**Critère de validation Phase 3** : une conversation suffisamment engagée
déclenche la proposition de capture, l'email de résumé part bien (visible
dans les logs `developer.log` suivant le pattern existant), et le lead est
soit en base Supabase soit reçu par email si Supabase est down.

---

### Phase 4 — Optionnel, à ne PAS commencer sans validation explicite

Passage à un avatar 3D réaliste (Ready Player Me export GLB +
`model_viewer_plus`). Ne pas entamer cette phase tant que les phases 1-3
n'ont pas prouvé leur valeur (taux de conversion mesuré via
`avatarLeadQualified`).

---

## CONTRAINTES TRANSVERSALES (toutes phases)

- Tout nouveau `Provider`/`Notifier` suit strictement la syntaxe Riverpod 3
  (`Notifier`/`AsyncNotifier`, pas `StateNotifier`).
- Aucune donnée en `localStorage`/`sessionStorage` web — utiliser
  `shared_preferences` (déjà en dépendance) ou `hive` (déjà en dépendance)
  si persistance locale nécessaire.
- Tout appel réseau protégé par `try/catch` avec `developer.log(...,
  name: 'NomDuService')`, suivant le style déjà présent dans tout le repo.
- Respecter le decoupage `data/` `notifiers/` `providers/` `services/`
  `views/screens/` `views/widgets/` par feature, identique à
  `lib/features/projets/` et `lib/features/experience/`.
- Ne jamais committer de clé API en dur — uniquement
  `String.fromEnvironment(...)`, et documenter la variable dans le
  workflow `.github/workflows/deploy.yml` (`--dart-define=...`) si besoin
  d'un secret CI supplémentaire.

---

## LIVRABLE ATTENDU DE CETTE SESSION

Commence UNIQUEMENT par la Phase 1. Ne pas anticiper le code des phases
suivantes. À la fin de la Phase 1, fournis un résumé des fichiers créés/
modifiés et les étapes manuelles restantes côté humain (ex: obtenir/
générer le fichier `.riv`, créer la table Supabase si Phase 3, etc.).
