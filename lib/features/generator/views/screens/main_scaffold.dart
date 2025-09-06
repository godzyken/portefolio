import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/providers.dart';
import 'package:portefolio/core/routes/router.dart';

import '../../../../constants/app_tab.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final router = ref.watch(goRouterProvider);

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
          final tab = AppTab.values[index];
          router.go(tab.path);
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: AppTab.values.map((t) => t.navItem).toList(),
      ),
    );
  }
}
