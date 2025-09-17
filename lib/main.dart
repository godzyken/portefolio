import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/grid_config_provider.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/features/home/views/screens/splash_screen.dart';
import 'package:portefolio/features/parametres/themes/services/theme_repository.dart';
import 'package:web/web.dart' as web;

import 'core/routes/router.dart';
import 'features/generator/views/widgets/responsive_scope.dart';
import 'features/parametres/themes/controller/theme_controller.dart';

// Clé injectée avec --dart-define
const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Injection dynamique du script Google Maps
  final script = web.HTMLScriptElement();
  script.src =
      'https://maps.googleapis.com/maps/api/js?key=$mapsApiKey&libraries=places';
  script.async = true;

  web.document.head!.append(script);

  final repo = ThemeRepository();
  final initial = await repo.loadTheme();

  runApp(
    ProviderScope(
      overrides: [
        themeControllerProvider.overrideWith(
          (ref) => ThemeController(repo, initial),
        ),
        navigatorKeyProvider.overrideWithValue(GlobalKey<NavigatorState>()),
      ],
      child: ResponsiveScope(child: MyApp()),
    ),
  );
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
      theme: theme.toThemeData(),
      darkTheme: theme.toThemeData(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return precache.when(
          data: (_) => child!,
          error: (err, stack) =>
              Scaffold(body: Center(child: Text('Erreur : $err'))),
          loading: () => const SplashScreen(),
        );
      },
    );
  }
}
