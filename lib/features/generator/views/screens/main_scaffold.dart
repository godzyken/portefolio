import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../../../../constants/app_tab.dart';
import '../../../../core/ui/widgets/ui_widgets_extentions.dart';
import '../../data/bubble_menu_item.dart';
import '../generator_widgets_extentions.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab =
        AppTab.fromLocation(GoRouterState.of(context).uri.toString());
    final config = currentTab.config(context, ref);
    final info = ref.watch(responsiveInfoProvider);

    void navigateTo(AppTab tab) {
      ref.read(currentLocationProvider.notifier).setLocation(tab.path);
      context.go(tab.path);
    }

    // Créer la liste des items pour le menu, en excluant 'Home'
    final bubbleItems = AppTab.values
        .where((tab) => tab != currentTab)
        .map((tab) => BubbleMenuItem(
              icon: tab.icon,
              label: tab.label,
              onPressed: () => navigateTo(tab),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText.titleLarge(config.title,
            overflow: TextOverflow.ellipsis),
        actions: config.actions,
      ),
      endDrawer: config.drawer,
      body: Stack(
        children: [
          // Le contenu de la page prend tout l'espace
          Positioned.fill(
            child: PageStorage(
              bucket: PageStorageBucket(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotate,
                    builder: (context, widget) {
                      final angle = rotate.value * 3.1416 / 2;
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(angle);
                      return IgnorePointer(
                        ignoring: animation.status != AnimationStatus.completed,
                        child: Transform(
                          transform: transform,
                          alignment: Alignment.centerLeft,
                          child: widget,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>(
                      GoRouterState.of(context).uri.toString()),
                  child: child,
                ),
              ),
            ),
          ),

          // LE MENU FLOTTANT AU-DESSUS DU CONTENU
          // Position: Top-left sous l'AppBar
          Positioned(
            top: -60, // Juste sous l'AppBar
            left: -60,
            child: GestureDetector(
              // Empêcher la propagation des clics au contenu dessous
              onTap: () {
                // Rien à faire, le menu gère lui-même son état
              },
              child: BubbleNavigationMenu(
                activeIcon: currentTab.icon,
                menuPosition: Alignment.topLeft,
                items: bubbleItems,
                isMobile: info.isMobile,
              ),
            ),
          ),

          // BULLE COMPARATIF EN HAUT À DROITE
          Positioned(
            top: info.isMobile ? 16 : 24,
            right: info.isMobile ? 16 : 24,
            child: ComparisonStatsView(),
          ),
        ],
      ),
      bottomNavigationBar: const PortfolioFooter(),
    );
  }
}
