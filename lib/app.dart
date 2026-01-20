import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/exceptions/error/error_screen.dart';
import 'core/provider/error_providers.dart';
import 'core/routes/router.dart';
import 'core/service/bootstrap_service.dart';
import 'core/ui/widgets/error_boundary.dart';
import 'features/home/views/screens/splash_screen.dart';
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

        return ErrorBoundary(
          contextLabel: 'MyFullApp',
          child: PrecacheWrapper(
            maxWaitDuration: const Duration(seconds: 20),
            child: content,
          ),
        );
      },
    );
  }
}
