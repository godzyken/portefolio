import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:portefolio/core/logging/app_logger.dart';

import 'app.dart';
import 'core/exceptions/app_provider_observer.dart';
import 'core/provider/config_env_provider.dart';
import 'core/provider/unified_image_provider.dart';
import 'core/service/bootstrap_service.dart';
import 'core/service/config_env.dart';
import 'features/generator/views/generator_widgets_extentions.dart';
import 'features/parametres/themes/controller/theme_controller.dart';
import 'features/parametres/themes/provider/theme_repository_provider.dart';

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
const _log = AppLogger('Main');

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runZonedGuarded(_boot, _onUncaughtError);
}

// ─────────────────────────────────────────────────────────────────────────────
// Boot
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) await Future.delayed(const Duration(milliseconds: 100));

  _configurePerformance();

  // ── Intercepteurs d'erreurs ────────────────────────────────────────────────

  // 1. Erreurs Flutter (widget build, layout, paint…)
  FlutterError.onError = _onFlutterError;

  // 2. Erreurs Dart hors-Flutter (isolats, Future non catchés…)
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.critical(
      'PlatformDispatcher — erreur non interceptée',
      error: error,
      stackTrace: stack,
    );
    return true; // true = erreur gérée, pas de crash natif
  };

  // ── Bootstrap ──────────────────────────────────────────────────────────────
  _log.info('Bootstrap en cours…');
  final bootstrap = await BootstrapService.initialize();
  _log.info(
      'Bootstrap terminé — ${bootstrap.prefs.getKeys().length} clés SharedPreferences');

  setUrlStrategy(const HashUrlStrategy());

  // ── ProviderContainer racine ───────────────────────────────────────────────
  final container = ProviderContainer(
    observers: const [AppProviderObserver()],
  );

  // ── Validation configuration ───────────────────────────────────────────────
  _validateEnv(container);

  // ── Images ────────────────────────────────────────────────────────────────
  final imageManager = container.read(unifiedImageManagerProvider);
  await imageManager.initialize();
  _log.info('UnifiedImageManager initialisé');

  // ── Singleton Env ──────────────────────────────────────────────────────────
  Env.init(container);

  // ── Lancement ─────────────────────────────────────────────────────────────
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ProviderScope(
        observers: const [AppProviderObserver()],
        overrides: [
          sharedPreferencesProvider.overrideWithValue(bootstrap.prefs),
          themeControllerProvider.overrideWith(ThemeController.new),
        ],
        child: ResponsiveScope(
          child: MyFullApp(bootstrap: bootstrap),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Handlers
// ─────────────────────────────────────────────────────────────────────────────

void _onFlutterError(FlutterErrorDetails details) {
  // Garde le comportement par défaut en debug (console rouge)
  if (kDebugMode) FlutterError.dumpErrorToConsole(details);

  _log.error(
    'FlutterError — ${details.library ?? "inconnu"} — ${details.exceptionAsString()}',
    error: details.exception,
    stackTrace: details.stack,
  );

  if (details.exception.toString().contains('GlobalKey')) {
    _log.info(
        '=== GlobalKey STACK === — ${details.stack.toString() ?? "inconnu"} — ${details.exceptionAsString()}');
  }
}

void _onUncaughtError(Object error, StackTrace stack) {
  // Dernier filet de sécurité : pas de ref disponible ici
  developer.log(
    '💥 [ZonedGuard] Erreur non interceptée',
    name: 'ZonedGuard',
    level: 1200,
    error: error,
    stackTrace: stack,
  );
  _log.critical('Erreur non interceptée (ZonedGuard)',
      error: error, stackTrace: stack);
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation config
// ─────────────────────────────────────────────────────────────────────────────

void _validateEnv(ProviderContainer container) {
  final validation = container.read(envConfigValidationProvider);

  if (!validation.isValid) {
    for (final e in validation.errors) {
      _log.warning('Config manquante : $e');
    }
  }
  if (validation.hasWarnings) {
    for (final w in validation.warnings) {
      _log.warning('Config warning : $w');
    }
  }
  if (validation.isValid && !validation.hasWarnings) {
    _log.info('Configuration d\'environnement OK');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance
// ─────────────────────────────────────────────────────────────────────────────

void _configurePerformance() {
  debugProfileBuildsEnabled = false;
  debugProfilePaintsEnabled = false;
  debugProfileLayoutsEnabled = false;

  PaintingBinding.instance.imageCache
    ..maximumSize = 100
    ..maximumSizeBytes = 50 * 1024 * 1024;

  // Frames lentes — debug uniquement, developer.log (pas debugPrint)
  assert(() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final ms = t.totalSpan.inMilliseconds;
        if (ms > 16) {
          developer.log('⚠️ Frame lente : ${ms}ms',
              name: 'Performance', level: 900);
        }
      }
    });
    return true;
  }());

  _log.info('Configuration performance appliquée');
}
