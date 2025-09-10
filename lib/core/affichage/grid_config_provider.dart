import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Objet immuable retourné par le provider
class GridConfig {
  final int columns;
  final double aspectRatio;
  const GridConfig(this.columns, this.aspectRatio);
}

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (_) => GlobalKey<NavigatorState>(),
);
