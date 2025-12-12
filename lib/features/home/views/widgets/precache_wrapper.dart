import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/precache_providers.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../screens/splash_screen.dart';

/// Widget qui gère le précache des assets avec options
class PrecacheWrapper extends ConsumerStatefulWidget {
  final Widget? child;

  /// Si true, utilise le précache parallèle (plus rapide mais plus de charge)
  //final bool useParallelPrecache;

  /// Durée max d'attente avant de continuer même si le précache n'est pas terminé
  final Duration? maxWaitDuration;

  const PrecacheWrapper({
    super.key,
    required this.child,
    this.maxWaitDuration = const Duration(seconds: 30),
  });

  @override
  ConsumerState<PrecacheWrapper> createState() => _PrecacheWrapperState();
}

class _PrecacheWrapperState extends ConsumerState<PrecacheWrapper> {
  bool _forceShowContent = false;

  @override
  void initState() {
    super.initState();

    // Timeout de sécurité : afficher le contenu même si le précache n'est pas fini
    if (widget.maxWaitDuration != null) {
      Future.delayed(widget.maxWaitDuration!, () {
        if (mounted && !_forceShowContent) {
          setState(() {
            _forceShowContent = true;
          });
          debugPrint('⏱️ Timeout atteint, affichage forcé du contenu');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si le timeout est atteint, afficher directement le contenu
    if (_forceShowContent) {
      return widget.child ?? const SizedBox.shrink();
    }

    // Choisir le bon provider selon la configuration

    final precacheAsync = ref.watch(precacheNotifierProvider);

    return precacheAsync.when(
      data: (_) {
        debugPrint('✅ Tous les assets sont précachés');
        return widget.child ?? const SizedBox.shrink();
      },
      loading: () {
        debugPrint('⏳ Chargement des assets...');
        return const SplashScreen();
      },
      error: (err, stack) {
        debugPrint('❌ Erreur de précache: $err');
        debugPrint('Stack: $stack');

        // Afficher le splash avec possibilité de continuer
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const ResponsiveText.displaySmall(
                  'Chargement...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ResponsiveText.displaySmall(
                    'Certaines ressources n\'ont pas pu être chargées.\n'
                    'L\'application continuera avec les ressources disponibles.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _forceShowContent = true;
                    });
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const ResponsiveText.bodySmall('Continuer quand même'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // Réessayer le précache
                    ref.invalidate(precacheNotifierProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Variante simple qui utilise uniquement le précache critique
class FastPrecacheWrapper extends ConsumerWidget {
  final Widget? child;

  const FastPrecacheWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final precacheAsync = ref.watch(precacheNotifierProvider);

    return precacheAsync.when(
      data: (_) => child ?? const SizedBox.shrink(),
      loading: () => const SplashScreen(),
      error: (_, __) => child ?? const SizedBox.shrink(),
    );
  }
}
