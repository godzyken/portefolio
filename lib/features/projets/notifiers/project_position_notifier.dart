import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectPositionsNotifier extends StateNotifier<Map<String, Offset>> {
  ProjectPositionsNotifier() : super({});

  void updatePosition(String id, Offset offset) {
    state = {...state, id: offset};
  }
}
