enum ScopePriority { core, important, optional, future, toConfirm }

class ScopeItem {
  final String featureName;
  final String description;
  final ScopePriority priority;

  const ScopeItem({
    required this.featureName,
    required this.description,
    this.priority = ScopePriority.toConfirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'featureName': featureName,
      'description': description,
      'priority': priority.name,
    };
  }
}

class ScopeDefinition {
  final List<ScopeItem> items;

  const ScopeDefinition({this.items = const []});

  List<ScopeItem> get mvpItems => items
      .where((i) =>
          i.priority == ScopePriority.core ||
          i.priority == ScopePriority.important)
      .toList();
  List<ScopeItem> get options =>
      items.where((i) => i.priority == ScopePriority.optional).toList();
  List<ScopeItem> get futureItems =>
      items.where((i) => i.priority == ScopePriority.future).toList();

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
