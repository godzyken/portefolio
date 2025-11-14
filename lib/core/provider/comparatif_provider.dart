import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/json_data_provider.dart';

import '../../features/home/data/comparatifs_data.dart';

final comparatifByIdProvider = Provider.family<Comparatif?, String>((ref, id) {
  final comparatif = ref.watch(comparaisonsJsonProvider).asData?.value ?? [];
  try {
    return comparatif.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
