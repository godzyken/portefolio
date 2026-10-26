import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:portefolio/landing_pages/pages/landing_amoa_page.dart';
import 'package:portefolio/landing_pages/pages/landing_flutter_page.dart';
import '../../features/about/views/screens/legal_mentions_screen.dart';
import '../../features/admin/views/screens/admin_dashboard_screen.dart';
import '../../features/admin/views/screens/admin_login_screen.dart';
import '../../features/admin/views/screens/admin_reset_password_screen.dart';
import '../../features/avatar/views/screens/avatar_screen.dart';
import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/conversion/views/screens/qualification_wizard_screen.dart';
import '../../features/diagnostic/views/screens/diagnostic_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/generator_extentions_screens.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/home/views/screens/splash_screen.dart';
import '../../features/offers/views/screens/offer_detail_screen.dart';
import '../../features/offers/views/screens/offers_catalog_screen.dart';
import '../../features/parametres/themes/views/screens/theme_settings_page.dart';
import '../../features/project_wizard/views/screens/project_wizard_screen.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../notifier/notifiers.dart';
import '../provider/providers.dart';

/// Capture la route réellement demandée par l'utilisateur (deep link web
/// via HashUrlStrategy, ex: recharger sur /#/avatar) AVANT que
/// `initialLocation: '/splash'` ne l'écrase.
String _resolveDeepLinkTargetRoute() {
  if (!kIsWeb) return '/';
  final fragment = Uri.base.fragment;
  debugPrint('🔍 [Router] Uri.base = ${Uri.base} | fragment = "$fragment"');
  if (fragment.isEmpty || fragment == '/splash' || fragment == '/') {
    debugPrint(
        '🔍 [Router] → deepLinkTarget résolu à "/" (fragment vide/splash/racine)');
    return '/';
  }
  final resolved = fragment.startsWith('/') ? fragment : '/$fragment';
  debugPrint('🔍 [Router] → deepLinkTarget résolu à "$resolved"');
  return resolved;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);
  final deepLinkTarget = _resolveDeepLinkTargetRoute();
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
              TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Retour')),
            ],
          ),
        ),
      ),
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (_, __) => SplashScreen(targetRoute: deepLinkTarget),
        ),

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

        GoRoute(
          path: '/project-wizard',
          name: 'project_wizard',
          builder: (_, __) => const ProjectWizardScreen(),
        ),

        GoRoute(
          path: '/start-project',
          name: 'start_project',
          builder: (_, __) => const QualificationWizardScreen(),
        ),

        // Catalogue d'offres (conversion)
        GoRoute(
          path: '/offres',
          name: 'offers_catalog',
          builder: (_, state) {
            final cat = state.uri.queryParameters['category'];
            final sid = state.uri.queryParameters['service'];
            return OffersCatalogScreen(
              highlightCategory: cat,
              highlightServiceId: sid,
            );
          },
          routes: [
            GoRoute(
              path: ':serviceId',
              name: 'offer_detail',
              builder: (_, state) => OfferDetailScreen(
                serviceId: state.pathParameters['serviceId']!,
              ),
            ),
          ],
        ),

        // Alias court catalogue
        GoRoute(
          path: '/o',
          name: 'offers_short',
          redirect: (_, __) => '/offres',
        ),

        // Compat: anciennes URLs /tarifs/:id → fiche offre
        GoRoute(
          path: '/tarifs/:serviceId',
          name: 'pricing_rationale',
          builder: (_, state) => OfferDetailScreen(
            serviceId: state.pathParameters['serviceId']!,
          ),
        ),

        // Landings (long)
        GoRoute(
          path: '/landing/flutter',
          name: 'landing_flutter',
          builder: (_, __) => const LandingFlutterPage(),
        ),
        GoRoute(
          path: '/landing/amoa',
          name: 'landing_amoa',
          builder: (_, __) => const LandingAmoaPage(),
        ),

        // Alias courts — idéaux réseaux sociaux
        GoRoute(
          path: '/f',
          name: 'landing_flutter_short',
          builder: (_, __) => const LandingFlutterPage(),
        ),
        GoRoute(
          path: '/flutter',
          name: 'landing_flutter_alias',
          builder: (_, __) => const LandingFlutterPage(),
        ),
        GoRoute(
          path: '/a',
          name: 'landing_amoa_short',
          builder: (_, __) => const LandingAmoaPage(),
        ),
        GoRoute(
          path: '/amoa',
          name: 'landing_amoa_alias',
          builder: (_, __) => const LandingAmoaPage(),
        ),

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
