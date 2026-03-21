import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/router.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (_) => GlobalKey<NavigatorState>(debugLabel: 'navigator_key_provider'),
);

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return ref.watch(goRouterProvider).configuration.navigatorKey;
});
