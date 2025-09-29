import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectPositionsNotifier extends Notifier<Map<String, Offset>> {
  @override
  Map<String, Offset> build() {
    return {};
  }

  void updatePosition(String id, Offset offset) {
    state = {...state, id: offset};
  }
}
