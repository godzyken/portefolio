import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timelineScrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();

  ref.onDispose(() => controller.dispose());

  return controller;
});
