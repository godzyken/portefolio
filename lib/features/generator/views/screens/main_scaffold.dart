import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/provider/providers.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _getIndex(String location) {
    if (location.startsWith('/experiences')) return 1;
    if (location.startsWith('/projects')) return 2;
    if (location.startsWith('/contact')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getIndex(location);
    final title = ref.watch(appBarTitleProvider);
    final actions = ref.watch(appBarActionsProvider);
    final drawer = ref.watch(appBarDrawerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: actions,
      ),
      endDrawer: drawer,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/experiences');
              break;
            case 2:
              context.go('/projects');
              break;
            case 3:
              context.go('/contact');
              break;
          }
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Expériences'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Contact'),
        ],
      ),
    );
  }
}
