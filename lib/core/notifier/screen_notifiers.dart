import 'dart:ui' as ui;
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
    // Tente de récupérer la taille réelle de la fenêtre dès le départ
    final view = ui.PlatformDispatcher.instance.implicitView;
    if (view == null) return const Size(1280, 800);
    
    final size = view.physicalSize / view.devicePixelRatio;
    return size == Size.zero ? const Size(1280, 800) : size;
  }

  /// Mettre à jour la taille
  void setSize(Size newSize) {
    if (state != newSize) {
      state = newSize;
    }
  }
}
