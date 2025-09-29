import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../../../../constants/app_tab.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final tab = AppTab.values[index];

          // Mettre à jour la location courante
          ref.read(currentLocationProvider.notifier).setLocation(tab.path);

          // Naviguer vers la route
          context.go(tab.path);
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: AppTab.values.map((t) {
          final isActive = currentIndex == t.index;
          return NavigationDestination(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha((255 * 0.6).toInt()),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                t.icon,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
            ),
            selectedIcon: AnimatedScale(
              scale: 1.2,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(t.icon, color: Theme.of(context).colorScheme.primary),
            ),
            label: t.label,
          );
        }).toList(),
      ),
    );
  }
}
