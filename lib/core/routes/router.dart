import 'package:go_router/go_router.dart';

import '../../features/contact/views/screens/contact_screen.dart';
import '../../features/home/views/screens/extentions_screens.dart';

final GoRouter router = GoRouter(
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
              path: '/pdf',
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
