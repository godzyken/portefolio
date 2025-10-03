import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experience_screens_extentions.dart';
import '../../features/generator/views/screens/generator_extentions_screens.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../affichage/navigator_key_provider.dart';
import '../notifier/visited_page_notifier.dart';
import '../service/analytics_service.dart';

// GoRouter fourni via Riverpod
final goRouterProvider = Provider<GoRouter>((ref) {
  final analytics = ref.read(analyticsProvider);
  final notifier = ref.read(routerNotifierProvider);
  final navigatorKey = ref.watch(navigatorKeyProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [_RouteObserver(ref), GAObserver(analytics)],
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
                path: 'pdf',
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
    refreshListenable: notifier,
  );
});

class _RouteObserver extends NavigatorObserver {
  final Ref ref;
  _RouteObserver(this.ref);

  @override
  void didPush(Route route, Route? previousRoute) {
    final location = _getLocationFromRoute(route);
    if (location != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(visitedPagesProvider.notifier).markVisited(location);
      });
    }
    super.didPush(route, previousRoute);
  }

  String? _getLocationFromRoute(Route route) {
    // Essaye d'obtenir le nom de la route
    if (route.settings.name != null) {
      return route.settings.name;
    }

    // Fallback pour obtenir le path depuis les arguments
    final arguments = route.settings.arguments;
    if (arguments is Map && arguments.containsKey('location')) {
      return arguments['location'] as String?;
    }

    return null;
  }
}

class GAObserver extends NavigatorObserver {
  final AnalyticsService analytics;

  GAObserver(this.analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    _sendPageView(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _sendPageView(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _sendPageView(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  void _sendPageView(Route route) {
    final path = _getPathFromRoute(route);
    analytics.pageview(path);
  }

  String _getPathFromRoute(Route route) {
    if (route.settings.name != null) {
      return route.settings.name!;
    }

    final arguments = route.settings.arguments;
    if (arguments is Map && arguments.containsKey('location')) {
      return arguments['location'] as String;
    }

    return route.toString();
  }
}
