import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/affichage/navigator_key_provider.dart';
import 'core/provider/providers.dart';
import 'core/routes/router.dart';
import 'features/generator/views/widgets/responsive_scope.dart';
import 'features/parametres/themes/controller/theme_controller.dart';

// ====================
// MAIN DEBUG (Étape 1)
// ====================
void main() {
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
}

// ======================
// MAIN ROUTER (Étape 2)
// ======================
void mainRouter() {
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
    );
  }
}

// ======================
// MAIN FULL (Étape 3)
// ======================
void mainFull() {
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
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(goRouterProvider);
    final precache = ref.watch(precacheAllAssetsProvider);

    return MaterialApp.router(
      title: 'Portfolio PDF',
      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      routerConfig: router,
      builder: (context, child) {
        return precache.when(
          data: (_) => child ?? const Text("Erreur UI"),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Erreur: $err")),
        );
      },
    );
  }
}
