import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/experience/data/experiences_data.dart';

class ExperiencesNotifier extends Notifier<List<Experience>> {
  @override
  List<Experience> build() => [];

  void setExperience(List<Experience> exp) => state = exp;
  void clearExperience() => state = [];
}

class ExperienceFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? f) => state = f;
}
