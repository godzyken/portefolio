import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/views/screens/legal_mentions_screen.dart';
import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/generator_extentions_screens.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/home/views/screens/splash_screen.dart';
import '../../features/parametres/themes/views/screens/theme_settings_page.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../notifier/notifiers.dart';
import '../provider/providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);
  // On crée les clés DIRECTEMENT ici
  // Elles seront recréées si le provider est invalidé (ex: logout)
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  try {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [],
      initialLocation: '/splash',
      routes: [
        // ── Splash (hors ShellRoute pour éviter la navbar) ─────────────
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (_, __) => const SplashScreen(targetRoute: '/'),
        ),

        // ── Shell principal (navbar, scaffold partagé) ──────────────────
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/experiences',
              name: 'experiences',
              builder: (_, __) => const ExperiencesScreen(),
            ),
            GoRoute(
              path: '/projects',
              name: 'projects',
              builder: (_, __) => const ProjectsScreen(),
              routes: [
                GoRoute(
                  path: 'pdf',
                  name: 'pdf',
                  builder: (_, __) => const PdfScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/contact',
              name: 'contact',
              builder: (_, __) => const ContactScreen(),
            ),
            GoRoute(
              path: '/legal',
              name: 'legal',
              builder: (_, __) => const LegalMentionsScreen(),
            ),
            GoRoute(
              path: '/theme_settings',
              name: 'theme_settings',
              builder: (_, __) => const ThemeSettingsPage(),
            ),
            GoRoute(
              path: '/wakatime_settings',
              name: 'wakatime_settings',
              builder: (_, __) => const WakaTimeSettingsScreen(),
            ),
          ],
        ),
      ],
      refreshListenable: _RouterListenable(notifier),
    );
  } catch (e, st) {
    debugPrint('❌ Erreur GoRouter: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }
});

class _RouterListenable extends Listenable {
  final RouterNotifier notifier;
  _RouterListenable(this.notifier);

  @override
  void addListener(VoidCallback listener) => notifier.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      notifier.removeListener(listener);
}
