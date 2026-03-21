import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/screen_notifiers.dart';

/// 🔹 Titre dynamique de l’AppBar
final appBarTitleProvider = NotifierProvider<AppBarTitleNotifier, String>(
    AppBarTitleNotifier.new,
    name: 'AppBarTitle');

/// 🔹 Actions dynamiques de l’AppBar
final appBarActionsProvider =
    NotifierProvider<AppBarActionsNotifier, List<Widget>>(
        AppBarActionsNotifier.new,
        name: 'AppBarActions');

/// 🔹 Drawer dynamique
final appBarDrawerProvider = NotifierProvider<AppBarDrawerNotifier, Widget?>(
    AppBarDrawerNotifier.new,
    name: 'AppBarDrawer',
    isAutoDispose: true);
