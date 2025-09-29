import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exeptions/state/global_error_state.dart';

/// 🔹 Notifier pour gérer l'état global des erreurs
class GlobalErrorNotifier extends Notifier<GlobalErrorState?> {
  @override
  GlobalErrorState? build() => null;

  void setError(GlobalErrorState error) => state = error;
  void clearError() => state = null;
}
