import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  Timer? _resizeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // On attend la fin de la première frame pour mettre à jour
    WidgetsBinding.instance.addPostFrameCallback((_) => _safeUpdateSize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resizeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Déclenche seulement après un léger délai pour éviter les rebuilds multiples
    _resizeTimer?.cancel();
    _safeUpdateSize();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _safeUpdateSize() {
    if (!mounted) return;
    final mq = MediaQuery.maybeOf(context);
    if (mq == null || mq.size == Size.zero) return;

    final newSize = mq.size;
    final currentSize = ref.read(screenSizeProvider);
    if (currentSize != newSize) {
      Future.microtask(() {
        if (mounted) {
          ref.read(screenSizeProvider.notifier).setSize(newSize);
        }
      });
    }
  }
}
