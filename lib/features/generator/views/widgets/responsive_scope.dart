import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';

class ResponsiveScope extends ConsumerStatefulWidget {
  final Widget child;
  const ResponsiveScope({super.key, required this.child});

  @override
  ConsumerState<ResponsiveScope> createState() => _ResponsiveScopeState();
}

class _ResponsiveScopeState extends ConsumerState<ResponsiveScope>
    with WidgetsBindingObserver {
  bool _pendingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Mise à jour initiale après build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _scheduleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Évite les mises à jour multiples : ne s'exécute qu'une fois par frame
  void _scheduleUpdate() {
    if (_pendingUpdate) return;
    _pendingUpdate = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pendingUpdate = false;
      _updateSize();
    });
  }

  void _updateSize() {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null || mq.size == Size.zero) return;

    final newSize = mq.size;
    final currentSize = ref.read(screenSizeProvider);

    if (currentSize != newSize) {
      ref.read(screenSizeProvider.notifier).setSize(newSize);
    }
  }
}
