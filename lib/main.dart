import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:portefolio/core/exceptions/handler/global_exeption_handler.dart';
import 'package:portefolio/core/logging/app_logger.dart';

import 'core/exceptions/error/error_screen.dart';
import 'core/provider/config_env_provider.dart';
import 'core/provider/error_providers.dart';
import 'core/provider/providers.dart';
import 'core/routes/router.dart';
import 'core/service/bootstrap_service.dart';
import 'core/service/config_env.dart';
import 'core/ui/widgets/ui_widgets_extentions.dart';
import 'features/generator/views/generator_widgets_extentions.dart';
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
void main() {
  //BindingBase.debugZoneErrorsAreFatal = false;
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runZonedGuarded(
    () async {
      // ✅ Patch pour le bug du MouseTracker au démarrage web
      if (kIsWeb) await Future.delayed(const Duration(milliseconds: 100));
      // ⚡ Bootstrap avant le runApp
      final bootstrap = await BootstrapService.initialize();
      developer.log(
          '✅ Bootstrap terminé, prefs loaded: ${bootstrap.prefs.getKeys().length}');

      setUrlStrategy(const HashUrlStrategy());

      // Debug Flutter
      debugProfileBuildsEnabled = true;
      debugProfilePaintsEnabled = true;
      debugProfileLayoutsEnabled = true;

      // Capturer les erreurs Flutter
      FlutterError.onError = (details) {
        debugPrint('Flutter Error: ${details.exceptionAsString()}');
        debugPrint('Stack trace: ${details.stack}');
      };

      final container = ProviderContainer();
      final validation = container.read(envConfigValidationProvider);

      if (!validation.isValid) {
        developer.log('⚠️ Erreurs de configuration:');
        for (final e in validation.errors) {
          developer.log('  - $e');
        }
      }
      if (validation.hasWarnings) {
        developer.log('⚠️ Warnings:');
        for (final w in validation.warnings) {
          developer.log('  - $w');
        }
      } else {
        developer.log('✅ Configuration d’environnement OK');
      }

      Env.init(container);

      runApp(UncontrolledProviderScope(
        container: container,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(bootstrap.prefs),
            themeControllerProvider.overrideWith(ThemeController.new),
          ],
          child: ResponsiveScope(
            child: MyFullApp(
              bootstrap: bootstrap,
            ),
          ),
        ),
      ));
    },
    (error, stack) {
      // Logger global en cas d'erreur non interceptée
      globalContainer.read(loggerProvider('ZonedGuard')).log(
            'Erreur non interceptée',
            level: LogLevel.error,
            error: error,
            stackTrace: stack,
          );
    },
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

    return MaterialApp.router(
      title: 'Portfolio',
      theme: themeData,
      darkTheme: themeData,
      themeMode: themeMode.mode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      /// Le builder te permet d’intercepter tous les widgets
      builder: (context, child) {
        final globalError = ref.watch(globalErrorProvider);

        // Gestion du thème
        Widget content = themeAsync.when(
          data: (_) => child!,
          loading: () => const SplashScreen(),
          error: (err, stack) => ErrorScreen(error: err, stackTrace: stack),
        );

        if (globalError != null) {
          return ErrorScreen(
            error: globalError.message,
            onRetry: () => ref.read(globalErrorProvider.notifier).clearError(),
            onGoHome: () => ref.read(globalErrorProvider.notifier).clearError(),
          );
        }

        // On centralise ici la gestion des erreurs globales :
        return ErrorBoundary(
          contextLabel: 'MyFullApp',
          child: PrecacheWrapper(
            useParallelPrecache: true,
            maxWaitDuration: const Duration(seconds: 20),
            child: content,
          ),
        );
      },
    );
  }
}
