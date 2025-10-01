import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/affichage/navigator_key_provider.dart';
import 'core/routes/router.dart';
import 'features/generator/views/widgets/responsive_scope.dart';
import 'features/home/views/screens/splash_screen.dart';
import 'features/home/views/widgets/precache_wrapper.dart';
import 'features/parametres/themes/controller/theme_controller.dart';

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
      body: const Center(
        child: Text(
          "Étape 1 OK ✅\nFlutter fonctionne",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
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
void main() {
  // Capturer les erreurs Flutter
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(ThemeController.new),
        navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
      ],
      child: const ResponsiveScope(child: MyFullApp()),
    ),
  );
}

class MyFullApp extends ConsumerWidget {
  const MyFullApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeFutureProvider);
    final router = ref.watch(goRouterProvider);

    return themeAsync.when(
      data: (theme) {
        return MaterialApp.router(
          title: 'Portfolio PDF',
          theme: theme.toThemeData(),
          darkTheme: theme.toThemeData(),
          themeMode: ThemeMode.dark,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Ici on wrappe avec le système de précache
            return PrecacheWrapper(child: child);
          },
        );
      },
      loading: () => MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
      error: (err, stack) {
        debugPrint("Erreur de précache: $err");
        debugPrint("Stack: $stack");
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
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
