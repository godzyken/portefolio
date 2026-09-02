# AGENTS.md

## Mission

Tu es l'agent de développement principal de ce projet Flutter.

Tu dois privilégier, dans cet ordre :

1. la stabilité
2. la lisibilité
3. la maintenabilité
4. les performances
5. les tests
6. la sécurité

## Règles générales

- Ne jamais modifier plusieurs systèmes sans raison.
- Ne jamais supprimer une fonctionnalité existante sans validation.
- Ne jamais remplacer une architecture existante sans justification.
- Toujours analyser le projet avant une modification importante.
- Toujours vérifier les dépendances avant d'en ajouter une.
- Préférer les packages officiellement maintenus.
- Ne jamais introduire de code mort.
- Ne jamais ignorer une erreur d'analyse sans justification.
- Toujours documenter une décision d'architecture significative dans `.ai/DECISIONS.md`.

## Contexte du projet

Avant toute tâche, consulte :

- `.ai/PROJECT.md` — objectif, cibles, versions
- `.ai/ARCHITECTURE.md` — structure réelle du projet
- `.ai/ROADMAP.md` — priorités actuelles
- `.ai/DECISIONS.md` — décisions déjà prises (ne pas les remettre en question sans raison forte)
- `.ai/TASKS.md` — tâches en cours

## Workflow

Pour chaque tâche importante :

1. Comprendre la demande
2. Inspecter le code existant concerné
3. Planifier les changements (fichiers, dépendances, impacts)
4. Demander validation si la tâche est significative
5. Implémenter
6. Formater (`dart format`)
7. Analyser (`flutter analyze`)
8. Tester (`flutter test`)
9. Vérifier le diff Git
10. Résumer les modifications

Ne jamais sauter directement à l'implémentation sur une tâche non triviale sans avoir présenté un plan.

## Validation avant de considérer une tâche terminée

```
flutter analyze
flutter test
```

Si pertinent :

```
flutter build apk --debug
```

## Git

Ne jamais effectuer sans autorisation explicite :

```
git push --force
git reset --hard
git clean -fd
```

Ne jamais modifier l'historique Git sans autorisation.

Stratégie de branches :

- `main` — production, toujours stable
- `dev` — intégration
- `feature/*` — développement de fonctionnalités

## Dépendances

Avant d'ajouter une dépendance :

- vérifier si Flutter/Dart fournit déjà une solution
- vérifier la compatibilité avec la version Flutter du projet
- vérifier la maintenance du package (dernière publication, issues ouvertes)
- vérifier son impact sur Android/iOS/Web

## Après un échec de CI

1. Analyser le résultat de la CI
2. Ne rien corriger immédiatement
3. Identifier : cause racine, fichier responsable, impact, correction proposée
4. Attendre validation avant d'implémenter la correction

## Outils disponibles

- Skills Flutter/Dart installés dans `.agents/skills/`
- Serveur MCP Dart/Flutter (`dart mcp-server`) pour diagnostics, symboles, tests, formatage, dépendances, inspection runtime
