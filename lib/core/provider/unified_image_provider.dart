import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../service/unified_image_manager.dart';

/// Provider pour le gestionnaire d'images unifié
final unifiedImageManagerProvider =
    ChangeNotifierProvider<UnifiedImageManager>((ref) {
  return UnifiedImageManager();
});

/// Provider d'initialisation
final imageManagerInitProvider = FutureProvider<void>((ref) async {
  final manager = ref.read(unifiedImageManagerProvider);
  await manager.initialize();
});

/// Provider pour les statistiques du cache
final imageCacheStatsProvider = Provider<CacheStats>((ref) {
  final manager = ref.watch(unifiedImageManagerProvider);
  return manager.getStats();
});

/// Notifier pour gérer l'état du préchargement
class PreloadNotifier extends AsyncNotifier<PreloadResult?> {
  @override
  Future<PreloadResult?> build() async {
    return null;
  }

  Future<void> preloadCriticalImages(BuildContext context) async {
    state = const AsyncLoading();

    final manager = ref.read(unifiedImageManagerProvider);

    // Définir les images critiques avec priorités
    final criticalImages = [
      ImagePriority(
        'assets/images/logo_godzyken.png',
        strategy: PreloadStrategy.critical,
        priority: 0,
      ),
      ImagePriority(
        'assets/images/pers_do_am.png',
        strategy: PreloadStrategy.critical,
        priority: 1,
      ),
      ImagePriority(
        'assets/images/logos/flutter.svg',
        strategy: PreloadStrategy.critical,
        priority: 2,
      ),
      ImagePriority(
        'assets/images/logos/dart.svg',
        strategy: PreloadStrategy.critical,
        priority: 3,
      ),
    ];

    try {
      final result = await manager.preloadWithPriorities(
        criticalImages,
        context: context,
      );
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> preloadAllImages(
    List<String> paths,
    BuildContext context,
  ) async {
    final manager = ref.read(unifiedImageManagerProvider);

    try {
      final result = await manager.preloadBatch(
        paths,
        context: context,
      );
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clearCache() {
    final manager = ref.read(unifiedImageManagerProvider);
    manager.clearCache();
    state = const AsyncData(null);
  }
}

final preloadNotifierProvider =
    AsyncNotifierProvider<PreloadNotifier, PreloadResult?>(
  PreloadNotifier.new,
);

/// Widget CachedImage optimisé qui utilise le cache unifié
class CachedImage extends ConsumerWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool autoPreload;
  final Color? color;
  final BlendMode? colorBlendMode;

  const CachedImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.autoPreload = true,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(unifiedImageManagerProvider);

    // Auto-préchargement si activé
    if (autoPreload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          manager.preloadImage(path, context: context);
        }
      });
    }

    // Vérifier le cache
    final isSvg = path.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return _buildSvgImage(manager);
    } else {
      return _buildRasterImage(manager);
    }
  }

  Widget _buildRasterImage(UnifiedImageManager manager) {
    final cached = manager.getCachedImage(path);

    if (cached != null) {
      return Image(
        image: cached,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) => _buildError(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildSvgImage(UnifiedImageManager manager) {
    final cached = manager.getCachedSvg(path);

    if (cached != null) {
      return CustomPaint(
        painter: _SvgPainter(cached),
        size: Size(width ?? double.infinity, height ?? double.infinity),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
  }
}

/// Painter personnalisé pour les SVG
class _SvgPainter extends CustomPainter {
  final PictureInfo pictureInfo;

  _SvgPainter(this.pictureInfo);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Adapter la taille
    final pictureSize = pictureInfo.size;
    final scale = size.width / pictureSize.width;
    canvas.scale(scale);

    // Dessiner
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgPainter oldDelegate) {
    return oldDelegate.pictureInfo != pictureInfo;
  }
}

/// Widget pour afficher les stats du cache (debug)
class CacheStatsWidget extends ConsumerWidget {
  const CacheStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(imageCacheStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cache Stats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _StatRow('Total Assets', stats.totalAssets.toString()),
            _StatRow('Raster Loaded', stats.loadedRaster.toString()),
            _StatRow('SVG Loaded', stats.loadedSvg.toString()),
            _StatRow('Failed', stats.failed.toString()),
            _StatRow('Loading', stats.loading.toString()),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stats.loadProgress,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text(
              '${(stats.loadProgress * 100).toStringAsFixed(1)}% loaded',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
