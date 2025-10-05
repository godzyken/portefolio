/// Helper pour nettoyer et normaliser les chemins d'images
class ImagePathHelper {
  /// Nettoie un chemin d'image qui peut contenir des préfixes incorrects
  static String cleanImagePath(String path) {
    if (path.isEmpty) return path;

    // Si le chemin contient "assets/" suivi d'une URL, extraire juste l'URL
    if (path.contains('assets/http')) {
      final httpIndex = path.indexOf('http');
      if (httpIndex != -1) {
        return path.substring(httpIndex);
      }
    }

    // Supprimer les préfixes "assets/" pour les URLs
    if ((path.startsWith('http://') || path.startsWith('https://')) &&
        path.contains('assets/')) {
      return path.replaceAll('assets/', '');
    }

    // Décoder les URLs encodées (comme %253A -> :)
    if (path.contains('%')) {
      try {
        return Uri.decodeFull(path);
      } catch (e) {
        // Si le décodage échoue, retourner le chemin original
        return path;
      }
    }

    return path;
  }

  /// Nettoie une liste de chemins d'images
  static List<String> cleanImagePaths(List<String>? paths) {
    if (paths == null || paths.isEmpty) return [];
    return paths.map((path) => cleanImagePath(path)).toList();
  }

  /// Vérifie si un chemin est une URL web
  static bool isNetworkImage(String path) {
    final cleanPath = cleanImagePath(path);
    return cleanPath.startsWith('http://') || cleanPath.startsWith('https://');
  }

  /// Vérifie si un chemin est un asset local
  static bool isAssetImage(String path) {
    final cleanPath = cleanImagePath(path);
    return !isNetworkImage(cleanPath) &&
        (cleanPath.startsWith('assets/') ||
            cleanPath.startsWith('images/') ||
            !cleanPath.contains('://'));
  }
}
