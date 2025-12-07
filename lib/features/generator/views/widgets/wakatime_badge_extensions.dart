import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projets/providers/projects_wakatime_service_provider.dart';
import 'wakatime_badge.dart';

/// Extension pour permettre à WakaTimeBadgeWidget de lire son propre état de tracking
/// initial via Riverpod, pour des utilisations conditionnelles (comme dans build).
extension WakaTimeBadgeRiverpodExtension on WakaTimeBadgeWidget {
  AsyncValue<bool> watchTrackingStatus(WidgetRef ref) {
    return ref.watch(projectTrackingStatusProvider(projectName));
  }
}
