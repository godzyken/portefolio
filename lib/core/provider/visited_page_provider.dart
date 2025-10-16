import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/visited_page_notifier.dart';

final visitedPagesProvider =
    NotifierProvider<VisitedPagesNotifier, Set<String>>(
  VisitedPagesNotifier.new,
);
