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
    final currentTab = AppTab.values[currentIndex];
    final config = currentTab.config(context, ref);

    // ✅ Ajout : garder l’état de chaque page (Home, Projects, Contact)
    return Scaffold(
      appBar: AppBar(
        title: Text(config.title, overflow: TextOverflow.ellipsis),
        actions: config.actions,
      ),
      endDrawer: config.drawer,

      /// 🔥 On garde chaque page en mémoire, même lors des transitions
      body: PageStorage(
        bucket: PageStorageBucket(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            // ✅ Utilisation du cube effect 3D ici
            final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              builder: (context, widget) {
                final angle = rotate.value * 3.1416 / 2;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle);
                return Transform(
                  transform: transform,
                  alignment: Alignment.centerLeft,
                  child: widget,
                );
              },
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey<String>(GoRouterState.of(context).uri.toString()),
            child: child,
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final tab = AppTab.values[index];

          // Met à jour la route et l’état courant
          ref.read(currentLocationProvider.notifier).setLocation(tab.path);
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha((255 * 0.6).toInt()),
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
