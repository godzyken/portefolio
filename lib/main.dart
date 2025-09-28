import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/features/home/views/screens/splash_screen.dart';
import 'package:portefolio/features/parametres/themes/services/theme_repository.dart';

import 'core/affichage/navigator_key_provider.dart';
import 'core/routes/router.dart';
import 'features/generator/views/widgets/responsive_scope.dart';
import 'features/parametres/themes/controller/theme_controller.dart';
import 'features/parametres/themes/theme/theme_data.dart';

void main() async {
  // S'assurer que Flutter est complètement initialisé
  WidgetsFlutterBinding.ensureInitialized();

  /*// Ignorer complètement les erreurs geolocator sur web
  if (kIsWeb) {
    // Capturer et ignorer les erreurs geolocator_web
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = details.exception.toString().toLowerCase();
      if (error.contains('geolocator') ||
          error.contains('library not defined') ||
          error.contains('package:geolocator_web')) {
        // Ignorer silencieusement les erreurs geolocator
        if (kDebugMode) {
          print('Erreur geolocator ignorée: ${details.exception}');
        }
        return;
      }
      // Pour toutes les autres erreurs, les afficher normalement
      FlutterError.presentError(details);
    };

    // Gestion des erreurs asynchrones non capturées
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('geolocator') ||
          errorStr.contains('library not defined') ||
          errorStr.contains('package:geolocator_web')) {
        if (kDebugMode) {
          print('Erreur async geolocator ignorée: $error');
        }
        return true; // Marquer comme gérée
      }
      return false; // Laisser Flutter gérer les autres erreurs
    };
  }*/

  try {
    // Configuration des channels avant toute autre opération
    await _setupChannels();

    // Initialisation du thème
    final repo = ThemeRepository();
    final initial = await repo.loadTheme();

    // Lancement de l'application
    runApp(
      ProviderScope(
        overrides: [
          themeControllerProvider.overrideWith(
            (ref) => ThemeController(repo, initial),
          ),
          navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
        ],
        child: const ResponsiveScope(child: MyMinimalApp()),
      ),
    );
  } catch (error, stackTrace) {
    // Gestion d'erreur globale
    if (kDebugMode) {
      print('Erreur lors de l\'initialisation: $error');
      print('Stack trace: $stackTrace');
    }

    // Application de fallback en cas d'erreur
    runApp(
      ProviderScope(
        overrides: [
          navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
          themeControllerProvider.overrideWith(
            (ref) => ThemeController(ThemeRepository(), BasicTheme.fallback),
          ),
        ],
        child: const ResponsiveScope(child: MyApp()),
      ),
/*
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur d\'initialisation: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Redémarrer l'application
                    main();
                  },
                  child: const Text('Redémarrer'),
                ),
              ],
            ),
          ),
        ),
      ),
*/
    );
  }
}

Future<void> _setupChannels() async {
  try {
    // Configuration du channel lifecycle avec gestion d'erreur
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
      'flutter/lifecycle',
      (message) async {
        if (kDebugMode) {
          print('Lifecycle message reçu: $message');
        }
        return null;
      },
    );

    // Configuration pour d'autres channels
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
      'flutter/platform',
      (message) async {
        if (kDebugMode) {
          print('Platform message reçu: $message');
        }
        return null;
      },
    );

    // Configuration pour les channels de navigation si nécessaire
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
      'flutter/navigation',
      (message) async => null,
    );

    // Attendre que tous les channels soient configurés
    await Future.delayed(const Duration(milliseconds: 50));

    if (kDebugMode) {
      print('Tous les channels ont été configurés avec succès');
    }
  } catch (error) {
    if (kDebugMode) {
      print('Erreur lors de la configuration des channels: $error');
    }
    rethrow;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(goRouterProvider);
    final precache = ref.watch(precacheAllAssetsProvider);

    return MaterialApp.router(
      title: 'Portfolio PDF',
      debugShowCheckedModeBanner: false, // Masquer le banner debug
      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      // Note: Vous utilisez le même thème pour light et dark - est-ce intentionnel ?
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return precache.when(
          data: (_) {
            // S'assurer que child n'est pas null
            if (child == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Erreur: Interface utilisateur non disponible'),
                ),
              );
            }
            return child;
          },
          error: (err, stack) {
            if (kDebugMode) {
              print('Erreur de precache: $err');
              print('Stack trace: $stack');
            }
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Détails: $err',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Forcer le refresh du provider
                        ref.invalidate(precacheAllAssetsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SplashScreen(),
        );
      },
    );
  }
}

class MyMinimalApp extends ConsumerWidget {
  const MyMinimalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Debug Portfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DebugScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Debug Portfolio'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Flutter App fonctionne !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Les imports de base sont OK.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Text(
              'Étapes suivantes :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Décommentez les imports un par un',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '2. Identifiez lequel cause l\'erreur',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '3. Corrigez le fichier problématique',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test d\'interaction réussi !'),
              backgroundColor: Colors.green,
            ),
          );
        },
        tooltip: 'Test',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
