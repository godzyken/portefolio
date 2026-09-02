# Architecture

## Vue d'ensemble

```
UI (Widgets/Screens)
 ↓
Riverpod Providers (Controllers/State)
 ↓
Repositories / Services (Supabase, Local Storage, APIs)
 ↓
Data Sources (Network, Hive, SharedPreferences)
```

## Structure des dossiers

lib/
├── core/              # Code partagé (thème, navigation, logging, providers communs)
│   ├── affichage/     # Détection de taille d'écran, responsive
│   ├── ui/            # Extensions UI, widgets de base
│   └── service/       # Bootstrap, Supabase, etc.
├── features/          # Fonctionnalités découpées par domaine
│   ├── home/          # Page d'accueil
│   ├── about/         # Section "À propos"
│   ├── projects/      # Galerie de projets
│   ├── experience/    # Parcours et analytics d'activité
│   └── ...
└── main.dart          # Point d'entrée

## Modules principaux

- **Experience** : Visualisation du parcours professionnel et des compétences techniques.
- **Projects** : Vitrine des réalisations (E-Foot Amateur, EMAP, etc.).
- **Admin** : Interface de gestion via Supabase.

## Conventions de code

- Utilisation massive des extensions pour l'UI (`ui_widgets_extentions.dart`).
- Pattern Riverpod pour le state management.
- Responsive design via `ResponsiveInfo` et `ResponsiveBox`.
