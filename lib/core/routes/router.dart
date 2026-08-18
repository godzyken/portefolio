import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/avatar/views/screens/avatar_screen.dart';
import '../../features/about/views/screens/legal_mentions_screen.dart';
import '../../features/admin/views/screens/admin_dashboard_screen.dart';
import '../../features/admin/views/screens/admin_login_screen.dart';
import '../../features/admin/views/screens/admin_reset_password_screen.dart';
import '../../features/diagnostic/views/screens/diagnostic_screen.dart';
import '../../features/project_wizard/views/screens/project_wizard_screen.dart';
import '../../features/home/views/screens/pricing_rationale_screen.dart';
import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/generator_extentions_screens.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/home/views/screens/splash_screen.dart';
import '../../features/parametres/themes/views/screens/theme_settings_page.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../notifier/notifiers.dart';
import '../provider/providers.dart';

/// Capture la route réellement demandée par l'utilisateur (deep link web
/// via HashUrlStrategy, ex: recharger sur /#/avatar) AVANT que
/// `initialLocation: '/splash'` ne l'écrase. Sans ça, le splash renvoyait
/// systématiquement vers '/' quelle que soit l'URL demandée, ce qui faisait
/// passer brièvement par HomeScreen (et son CharacterViewer 3D) à chaque
/// chargement, même en arrivant directement sur /avatar.
String _resolveDeepLinkTargetRoute() {
  if (!kIsWeb) return '/';
  final fragment = Uri.base.fragment;
  if (fragment.isEmpty || fragment == '/splash' || fragment == '/') {
    return '/';
  }
  return fragment.startsWith('/') ? fragment : '/$fragment';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);
  final deepLinkTarget = _resolveDeepLinkTargetRoute();
  // On crée les clés DIRECTEMENT ici
  // Elles seront recréées si le provider est invalidé (ex: logout)
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  try {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page non trouvée : ${state.uri.path}'),
              TextButton(onPressed: () => context.go('/'), child: const Text('Retour')),
            ],
          ),
        ),
      ),
      initialLocation: '/splash',
      routes: [
        // ── Splash (hors ShellRoute pour éviter la navbar) ─────────────
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (_, __) => SplashScreen(targetRoute: deepLinkTarget),
        ),

        // ── Admin (formulaire de gestion des tarifs, hors navbar publique) ─
        GoRoute(
          path: '/admin/login',
          name: 'admin_login',
          builder: (_, __) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin/auth/reset',
          name: 'admin_reset_password',
          builder: (_, __) => const AdminResetPasswordScreen(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (_, __) => const AdminDashboardScreen(),
        ),

        // ── Assistant de Projet IA ────────────────────────────────────
        GoRoute(
          path: '/project-wizard',
          name: 'project_wizard',
          builder: (_, __) => const ProjectWizardScreen(),
        ),

        // ── Page publique "pourquoi ce tarif" (clic sur le prix) ─────────
        GoRoute(
          path: '/tarifs/:serviceId',
          name: 'pricing_rationale',
          builder: (_, state) => PricingRationaleScreen(
            serviceId: state.pathParameters['serviceId']!,
          ),
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
              path: '/diagnostic',
              name: 'diagnostic',
              builder: (_, __) => const DiagnosticScreen(),
            ),
            GoRoute(
              path: '/avatar',
              name: 'avatar',
              builder: (_, __) => const AvatarScreen(),
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
