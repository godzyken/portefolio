import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/exceptions/error/error_screen.dart';
import 'core/exceptions/error_notifier.dart';
import 'core/routes/router.dart';
import 'core/service/bootstrap_service.dart';
import 'core/ui/widgets/error_boundary.dart';
import 'features/home/views/widgets/precache_wrapper.dart';
import 'features/parametres/themes/controller/theme_controller.dart';
import 'features/parametres/themes/provider/theme_repository_provider.dart';
import 'features/parametres/themes/theme/theme_data.dart';

class MyFullApp extends ConsumerWidget {
  final BootstrapService bootstrap;
  const MyFullApp({super.key, required this.bootstrap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeLoaderProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final themeData = themeMode.toThemeData();

    // ── Thème en cours de chargement ──────────────────────────────────────────
    if (themeAsync.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: const Scaffold(
          backgroundColor: Color(0xFF0A0A0A),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
          ),
        ),
      );
    }

    // ── Erreur de chargement du thème ─────────────────────────────────────────
    if (themeAsync.hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          error: themeAsync.error!,
          stackTrace: themeAsync.stackTrace,
        ),
      );
    }

    // ── Erreur globale critique seulement (ex: ForceUpdate) ───────────────────
    // Les erreurs non-critiques (réseau, permission…) sont gérées localement
    // par chaque écran via errorNotifierProvider.
    final globalError = ref.watch(errorNotifierProvider);
    if (globalError != null && globalError.isCritical) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: ErrorScreen(
          error: globalError.message,
          onRetry: () => ref.read(errorNotifierProvider.notifier).clear(),
          onGoHome: () => ref.read(errorNotifierProvider.notifier).clear(),
        ),
      );
    }

    // ── Application complète ──────────────────────────────────────────────────
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
        return ErrorBoundary(
          contextLabel: 'MyFullApp',
          child: PrecacheWrapper(
            maxWaitDuration: const Duration(seconds: 20),
            child: child!,
          ),
        );
      },
    );
  }
}
