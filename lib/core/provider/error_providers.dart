import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/state/global_error_state.dart';
import '../notifier/error_notifiers.dart';

/// 🔹 Provider à utiliser dans l'app
final globalErrorProvider =
    NotifierProvider<GlobalErrorNotifier, GlobalErrorState?>(
        GlobalErrorNotifier.new);
