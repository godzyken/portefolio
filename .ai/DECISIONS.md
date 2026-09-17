# Architecture Decisions

## ADR-001

### Decision

Utilisation de Riverpod 3.x pour le state management global.

### Reason

Besoin de réactivité forte, testabilité et découplage des services.

### Date

2026-09-02

### Status

Accepted

## ADR-002

### Decision

Utilisation d'une architecture Feature-First.

### Reason

Facilite la scalabilité et le travail isolé sur chaque section du portfolio.

### Date

2026-09-02

### Status

Accepted

## ADR-003

### Decision

Utilisation obligatoire de Squoosh pour l'optimisation des images du projet au format **AVIF**.

### Reason

Le format AVIF offre une compression supérieure au WebP et JPEG, garantissant des temps de chargement ultra-rapides sur Netlify (SEO et performance) et minimisant l'empreinte du dépôt Git.

### Date

2026-09-02

### Status

Accepted
