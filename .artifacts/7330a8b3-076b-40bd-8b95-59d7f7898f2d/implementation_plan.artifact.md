# Plan d'implémentation - Correction de l'affichage des images et icônes de projets (Workshop & autres)

## Problématique
Certaines images et icônes de projets ne s'affichent plus dans le portfolio (notamment dans la vue bulles/devices, le mode carte et les icônes de technologies 3D, par exemple pour le projet WorkShop / Ultron, E-Foot Amateur, etc.).

## Cause racine identifiée

1. **`CachedImage` (`lib/core/provider/unified_image_provider.dart`)** :
   - `CachedImage` ne rendait une image QUE si elle avait déjà été préchargée en mémoire dans `_rasterProviders` / `_svgCache`.
   - Si l'image n'était pas encore en cache mémoire (ou si le préchargement avait échoué/expiré par timeout), `CachedImage` affichait indéfiniment un conteneur Shimmer ou une boîte d'erreur ("Réessayer") au lieu de basculer vers `AssetImage(cleanPath)` / `SvgPicture.asset(cleanPath)`.
   - Les bulles interactives (`DraggableBubble`) sur Desktop/Web utilisent exclusivement `CachedImage`.

2. **`UnifiedImageManager` (`lib/core/service/unified_image_manager.dart`)** :
   - En cas de timeout de préchargement (3s), l'image était ajoutée à `_failedPaths`, bloquant tout affichage ultérieur.
   - `initialize()` restreignait l'indexation aux seuls assets sous `assets/images/`, ignorant les autres sous-dossiers d'assets.

3. **Icônes de technologies (`lib/constants/tech_logos.dart` & `image_providers.dart`)** :
   - Les tags sans logo SVG dédié (comme `ESP8266`, `LAN`, `Offline Sync`, `IoT`, `Education`) se rabattaient sur une icône générique par défaut (`Icons.extension`).

4. **Projets sans liste d'images (`assets/data/projects.json`)** :
   - Les projets `e_foot_amateur` et `projet_comparison` avaient une liste `"image": []` vide.

## Modifications proposées

### 1. Robustesse de `CachedImage` & `SmartImage`
- [MODIFY] [unified_image_provider.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/provider/unified_image_provider.dart) : modifier `CachedImage` pour qu'il utilise le cache mémoire si disponible, ou bascule immédiatement sur `AssetImage` / `NetworkImage` / `SvgPicture.asset` avec `errorBuilder` de secours, évitant ainsi le blocage en Shimmer.
- [MODIFY] [smart_image.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/ui/widgets/smart_image.dart) : sécuriser la gestion des erreurs et du fallback d'image.

### 2. Gestionnaire d'images unifié (`UnifiedImageManager`)
- [MODIFY] [unified_image_manager.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/service/unified_image_manager.dart) :
  - Indexer tous les assets sous `assets/`.
  - Éviter le marquage fatal en `_failedPaths` en cas de simple dépassement de délai de préchargement.

### 3. Mappage des icônes & logos (`tech_logos.dart` & `image_providers.dart`)
- [MODIFY] [tech_logos.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/constants/tech_logos.dart) : enrichir `getIconFromName` pour associer des icônes explicites Material aux tags réseau, IoT, hardware, éducation, sport, etc.
- [MODIFY] [image_providers.dart](file:///C:/Users/soufi/StudioProjects/portefolio/lib/core/provider/image_providers.dart) : ajouter des alias et correspondances pour les clés de compétences.

### 4. Données des projets (`assets/data/projects.json`)
- [MODIFY] [projects.json](file:///C:/Users/soufi/StudioProjects/portefolio/assets/data/projects.json) : alimenter des visuels d'illustrations pour `e_foot_amateur` et `projet_comparison`.

## Vérification
1. Exécution des vérifications de syntaxe et d'analyse (`flutter analyze`).
2. Exécution de la suite de tests (`flutter test`).
