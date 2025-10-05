import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/animations/page_transitions.dart';

import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/main_scaffold.dart';
import '../../features/generator/views/screens/pdf_screen.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../affichage/navigator_key_provider.dart';
import '../notifier/notifiers.dart';
import '../notifier/visited_page_notifier.dart';
import '../provider/providers.dart';
import '../service/analytics_service.dart';

final goRouterFutureProvider = FutureProvider<GoRouter>((ref) async {
  final analytics = ref.read(analyticsProvider);
  final notifier = ref.watch(routerNotifierProvider.notifier);
  final navigatorKey = ref.read(navigatorKeyProvider);

  // Laisse un petit délai pour ne pas bloquer la frame initiale
  await Future.delayed(const Duration(milliseconds: 100));

  return GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      _CombinedObserver(ref, analytics),
    ],
    initialLocation: '/',
    routes: [
      ShellRoute(
        pageBuilder: (context, state, child) => CustomTransitionPageBuilder(
            type: TransitionType.cube,
            direction: notifier.direction,
            duration: const Duration(milliseconds: 600),
            child: const ExperiencesScreen()),
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
        ],
      ),
    ],
    refreshListenable: _RouterListenable(notifier),
  );
});

class _CombinedObserver extends NavigatorObserver {
  final Ref ref;
  final AnalyticsService analytics;
  _CombinedObserver(this.ref, this.analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    _handlePageChange(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _handlePageChange(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) _handlePageChange(previousRoute);
    super.didPop(route, previousRoute);
  }

  void _handlePageChange(Route route) {
    final path = _getPathFromRoute(route);
    // Async, ne bloque pas le thread principal
    unawaited(Future(() {
      ref.read(visitedPagesProvider.notifier).markVisited(path);
      analytics.pageview(path);
    }));
  }

  String _getPathFromRoute(Route route) {
    if (route.settings.name != null) return route.settings.name!;
    final args = route.settings.arguments;
    if (args is Map && args.containsKey('location'))
      return args['location'] as String;
    return route.toString();
  }
}

class _RouterListenable extends Listenable {
  final RouterNotifier notifier;
  _RouterListenable(this.notifier);

  @override
  void addListener(VoidCallback listener) => notifier.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      notifier.removeListener(listener);
}
