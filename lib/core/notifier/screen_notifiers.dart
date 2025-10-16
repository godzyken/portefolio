import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarTitleNotifier extends Notifier<String> {
  @override
  String build() => "Portfolio";

  void setTitle(String title) => state = title;
}

class AppBarActionsNotifier extends Notifier<List<Widget>> {
  @override
  List<Widget> build() => [];

  void setActions(List<Widget> actions) => state = actions;
  void clearActions() => state = [];
}

class AppBarDrawerNotifier extends Notifier<Widget?> {
  @override
  Widget? build() => null;

  void setDrawer(Widget drawer) => state = drawer;
  void clearDrawer() => state = null;
}

class ScreenSizeNotifier extends Notifier<Size> {
  @override
  Size build() {
    // Taille initiale (avant qu'on ne mesure l'écran)
    return Size.zero;
  }

  /// Mettre à jour la taille
  void setSize(Size newSize) {
    state = newSize;
  }
}
