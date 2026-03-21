import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/data/services_data.dart';
import '../notifier/generic_notifier.dart';
import '../notifier/service_notifiers.dart';
import 'json_data_provider.dart';

/// 🔹 Provider pour filtrer les services par catégorie
final servicesFilterProvider =
    NotifierProvider<ServiceFilterNotifier, ServiceCategory?>(
  ServiceFilterNotifier.new,
  name: 'ServicesFilter',
);

/// 🔹 Provider pour les services sélectionnés
final selectedServicesProvider =
    NotifierProvider<CollectionNotifier<Service>, List<Service>>(
  () => CollectionNotifier<Service>(),
  name: 'SelectedServices',
);

/// 🔹 Provider des services filtrés
final filteredServicesProvider = Provider<List<Service>>((ref) {
  final services = ref.watch(servicesJsonProvider).asData?.value ?? [];
  final filter = ref.watch(servicesFilterProvider);

  if (filter == null) return services;

  return services.where((s) => s.category == filter).toList();
}, name: 'FilteredServices');

/// 🔹 Provider pour obtenir un service par ID
final serviceByIdProvider = Provider.family<Service?, String>((ref, id) {
  final services = ref.watch(servicesJsonProvider).asData?.value ?? [];
  try {
    return services.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}, name: 'ServiceById');

/// 🔹 Provider pour obtenir les catégories disponibles
final availableCategoriesProvider = Provider<List<ServiceCategory>>((ref) {
  final services = ref.watch(servicesJsonProvider).asData?.value ?? [];
  final categories = services.map((s) => s.category).toSet().toList();
  categories.sort((a, b) => a.displayName.compareTo(b.displayName));
  return categories;
}, name: 'AvailableCategories');

/// 🔹 Provider pour compter les services par catégorie
final serviceCountByCategoryProvider =
    Provider.family<int, ServiceCategory>((ref, category) {
  final services = ref.watch(servicesJsonProvider).asData?.value ?? [];
  return services.where((s) => s.category == category).length;
}, name: 'ServiceCountByCategory');
