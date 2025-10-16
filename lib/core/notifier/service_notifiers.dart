import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/data/services_data.dart';

/// Notifier pour gérer le filtre de catégorie de services
class ServiceFilterNotifier extends Notifier<ServiceCategory?> {
  @override
  ServiceCategory? build() {
    return null; // Pas de filtre par défaut
  }

  /// Définir un filtre
  void setFilter(ServiceCategory? category) {
    state = category;
  }

  /// Basculer le filtre (si déjà actif, le désactiver)
  void toggleFilter(ServiceCategory category) {
    state = state == category ? null : category;
  }

  /// Effacer le filtre
  void clearFilter() {
    state = null;
  }

  /// Vérifier si un filtre est actif
  bool get hasFilter => state != null;
}

/// Notifier pour gérer les services sélectionnés (si besoin)
class SelectedServicesNotifier extends Notifier<List<Service>> {
  @override
  List<Service> build() {
    return [];
  }

  /// Ajouter un service
  void addService(Service service) {
    if (!state.contains(service)) {
      state = [...state, service];
    }
  }

  /// Retirer un service
  void removeService(Service service) {
    state = state.where((s) => s.id != service.id).toList();
  }

  /// Basculer la sélection d'un service
  void toggleService(Service service) {
    if (state.contains(service)) {
      removeService(service);
    } else {
      addService(service);
    }
  }

  /// Vérifier si un service est sélectionné
  bool isSelected(Service service) {
    return state.any((s) => s.id == service.id);
  }

  /// Effacer toutes les sélections
  void clearAll() {
    state = [];
  }

  /// Sélectionner tous les services d'une liste
  void selectAll(List<Service> services) {
    state = [...services];
  }

  /// Nombre de services sélectionnés
  int get selectedCount => state.length;
}
