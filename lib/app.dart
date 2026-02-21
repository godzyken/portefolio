import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/exceptions/error/error_screen.dart';
import 'core/provider/error_providers.dart';
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
    final globalError = ref.watch(globalErrorProvider);

    // ✅ Thème non chargé → on laisse GoRouter afficher /splash naturellement
    // (plus de SplashScreen ici comme fallback du thème)
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

    if (themeAsync.hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          error: themeAsync.error!,
          stackTrace: themeAsync.stackTrace,
        ),
      );
    }

    if (globalError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: ErrorScreen(
          error: globalError.message,
          onRetry: () => ref.read(globalErrorProvider.notifier).clearError(),
          onGoHome: () => ref.read(globalErrorProvider.notifier).clearError(),
        ),
      );
    }

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
