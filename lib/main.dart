import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/affichage/navigator_key_provider.dart';
import 'core/routes/router.dart';
import 'core/service/bootstrap_service.dart';
import 'features/generator/views/widgets/generator_widgets_extentions.dart';
import 'features/home/views/screens/splash_screen.dart';
import 'features/home/views/widgets/precache_wrapper.dart';
import 'features/parametres/themes/controller/theme_controller.dart';
import 'features/parametres/themes/provider/theme_repository_provider.dart';
import 'features/parametres/themes/theme/theme_data.dart';

// ====================
// ÉTAPE 1 : Test minimal
// Décommentez UNIQUEMENT cette section pour tester
// ====================
/*void main() {
  runApp(const MyMinimalApp());
}

class MyMinimalApp extends StatelessWidget {
  const MyMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Portfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DebugScreen(),
    );
  }
}

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug Portfolio")),
      body: const SafeArea(child: GeolocationTesterWidget()),
    );
  }
}*/

// ====================
// ÉTAPE 2 : Test avec Router
// Décommentez cette section après validation de l'étape 1
// ====================
/*void main() {
  runApp(
    ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(ThemeController.new),
        navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
      ],
      child: const ResponsiveScope(child: MyRouterApp()),
    ),
  );
}

class MyRouterApp extends ConsumerWidget {
  const MyRouterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Router Test',
      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}*/

// ====================
// ÉTAPE 3 : Application complète
// Version finale avec toutes les fonctionnalités
// ====================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturer les erreurs Flutter
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // ⚡ Bootstrap avant le runApp
  final bootstrap = await BootstrapService.initialize();
  developer.log(
      '✅ Bootstrap terminé, prefs loaded: ${bootstrap.prefs.getKeys().length}');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(bootstrap.prefs),
        themeControllerProvider.overrideWith(ThemeController.new),
        navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
      ],
      child: ResponsiveScope(
          child: MyFullApp(
        bootstrap: bootstrap,
      )),
    ),
  );
}

class MyFullApp extends ConsumerWidget {
  final BootstrapService bootstrap;
  const MyFullApp({super.key, required this.bootstrap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeLoaderProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final themeData = themeMode.toThemeData();

    // Le routeur est prêt, on peut utiliser MaterialApp.router
    return MaterialApp.router(
      title: 'Portfolio',
      theme: themeData,
      darkTheme: themeData,
      themeMode: themeMode.mode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        Widget content = themeAsync.when(
          data: (_) => child!,
          loading: () => const SplashScreen(), // Chargement du thème
          error: (err, stack) => ErrorScreen(
              err: err, stack: stack), // Erreur de chargement du thème
        );

        return PrecacheWrapper(
          useParallelPrecache: true,
          maxWaitDuration: const Duration(seconds: 20),
          child: content,
        );
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Object err;
  final StackTrace? stack;
  const ErrorScreen({super.key, required this.err, this.stack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Erreur de chargement",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(err.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
