# Skills Flutter/Dart

Ce dossier accueille les Agent Skills officiels Flutter et Dart.

## Installation

À la racine du projet :

```bash
npx skills add flutter/agent-plugins --skill '*' --agent universal --yes
npx skills add dart-lang/skills --skill '*' --agent universal --yes
```

Cela peuple `.agents/skills/` avec les skills couvrant notamment :

- architecture Flutter
- widgets
- responsive design
- navigation
- state management
- tests
- analyse statique
- dépendances

## Skills fournis par les packages du projet

Certains packages Dart/Flutter peuvent fournir leurs propres skills. Pour les découvrir et les
installer automatiquement :

```bash
dart run skills@ get --all
```

## Mise à jour

Relancer les mêmes commandes périodiquement pour récupérer les nouvelles versions des skills.

⚠️ Ce README est un espace réservé. Le contenu réel de `.agents/skills/` (sous-dossiers `flutter/`,
`dart/`, etc.) est généré par les commandes ci-dessus et ne doit pas être édité manuellement.
