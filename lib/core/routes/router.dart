import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/generator_extentions_screens.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../notifier/visited_page_notifier.dart';
import '../service/analytics_service.dart';

// Un navigatorKey global pour ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter fourni via Riverpod
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [_RouteObserver(ref), GAObserver(ref.read(analyticsProvider))],
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/experiences',
            name: 'experiences',
            builder: (context, state) => const ExperiencesScreen(),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: 'pdf', // ⚠️ pas de "/" devant sinon le nested break
                name: 'pdf',
                builder: (context, state) => const PdfScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/contact',
            name: 'contact',
            builder: (context, state) => const ContactScreen(),
          ),
        ],
      ),
    ],
  );
});

class _RouteObserver extends NavigatorObserver {
  final Ref ref;
  _RouteObserver(this.ref);

  @override
  void didPush(Route route, Route? previousRoute) {
    final location =
        route.settings.name ?? route.settings.arguments?.toString();
    if (location != null) {
      ref.read(visitedPagesProvider.notifier).markVisited(location);
    }
    super.didPush(route, previousRoute);
  }
}

class GAObserver extends NavigatorObserver {
  final AnalyticsService analytics;
  GAObserver(this.analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    final path = route.settings.name ?? route.toString();
    analytics.pageview(path);
    super.didPush(route, previousRoute);
  }
}
