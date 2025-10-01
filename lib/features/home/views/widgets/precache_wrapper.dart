import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/providers.dart';
import '../screens/splash_screen.dart';

/// Widget qui gère le précache des assets
class PrecacheWrapper extends ConsumerWidget {
  final Widget? child;

  const PrecacheWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final precacheAsync = ref.watch(precacheAllAssetsProvider);

    return precacheAsync.when(
      data: (_) {
        debugPrint('✅ Tous les assets sont précachés');
        return child ?? const SizedBox.shrink();
      },
      loading: () {
        debugPrint('⏳ Chargement des assets...');
        return const SplashScreen();
      },
      error: (err, stack) {
        debugPrint('❌ Erreur de précache: $err');
        debugPrint('Stack: $stack');

        // Afficher le splash avec une erreur mais continuer quand même
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                const Text(
                  'Chargement...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Certaines ressources n\'ont pas pu être chargées',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.6).toInt()),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Force le passage à l'app même avec l'erreur
                    ref.invalidate(precacheAllAssetsProvider);
                  },
                  child: const Text('Continuer quand même'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
