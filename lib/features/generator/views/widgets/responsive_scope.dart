import 'package:flutter/widgets.dart';
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // À chaque changement de dimension
  @override
  void didChangeMetrics() {
    _updateSize();
  }

  @override
  Widget build(BuildContext context) {
    // première mise à jour juste après le build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
    return widget.child;
  }

  void _updateSize() {
    final mq = MediaQuery.of(context);
    ref.read(screenSizeProvider.notifier).state = mq.size;
  }
}
