import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/generic_notifier.dart';

final visitedPagesProvider = NotifierProvider<SetNotifier<String>, Set<String>>(
  () => SetNotifier<String>(),
);
