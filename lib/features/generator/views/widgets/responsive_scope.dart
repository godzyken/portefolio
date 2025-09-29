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
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _safeUpdateSize();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _safeUpdateSize() {
    if (!mounted) return;
    final mq = MediaQuery.maybeOf(context);
    if (mq != null && mq.size != Size.zero) {
      ref.watch(screenSizeProvider.notifier).setSize(mq.size);
    }
  }
}
