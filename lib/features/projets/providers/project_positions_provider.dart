import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/project_position_notifier.dart';

/// Provider pour stocker les positions des bulles
final projectPositionsProvider =
    NotifierProvider<ProjectPositionsNotifier, Map<String, Offset>>(
        ProjectPositionsNotifier.new);
