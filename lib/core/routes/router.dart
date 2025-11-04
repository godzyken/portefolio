import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/views/screens/legal_mentions_screen.dart';
import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/experience/views/screens/experiences_screen.dart';
import '../../features/generator/views/screens/main_scaffold.dart';
import '../../features/generator/views/screens/pdf_screen.dart';
import '../../features/home/views/screens/home_screen.dart';
import '../../features/projets/views/screens/projects_screen.dart';
import '../affichage/navigator_key_provider.dart';
import '../notifier/notifiers.dart';
import '../provider/providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);
  final navigatorKey = ref.read(navigatorKeyProvider);

  try {
    return GoRouter(
      navigatorKey: navigatorKey,
      observers: [],
      initialLocation: '/',
      routes: [
        ShellRoute(
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
