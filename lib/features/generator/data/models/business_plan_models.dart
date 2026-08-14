
class TitledContent {
  final String title;
  final String content;

  const TitledContent({required this.title, required this.content});

  factory TitledContent.fromJson(Map<String, dynamic> json) {
    return TitledContent(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

class BusinessValue {
  final String title;
  final String description;

  const BusinessValue({required this.title, required this.description});

  factory BusinessValue.fromJson(Map<String, dynamic> json) {
    return BusinessValue(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class BusinessPositioning {
  final String title;
  final List<String> roles;

  const BusinessPositioning({required this.title, required this.roles});

  factory BusinessPositioning.fromJson(Map<String, dynamic> json) {
    return BusinessPositioning(
      title: json['title'] as String,
      roles: (json['roles'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class BusinessMarket {
  final String problem;
  final String solution;

  const BusinessMarket({required this.problem, required this.solution});

  factory BusinessMarket.fromJson(Map<String, dynamic> json) {
    return BusinessMarket(
      problem: json['problem'] as String,
      solution: json['solution'] as String,
    );
  }
}

class BusinessPlanService {
  final String id;
  final String title;
  final String description;
  final List<String> deliverables;

  const BusinessPlanService({
    required this.id,
    required this.title,
    required this.description,
    this.deliverables = const [],
  });

  factory BusinessPlanService.fromJson(Map<String, dynamic> json) {
    return BusinessPlanService(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      deliverables: (json['deliverables'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class BusinessExpertiseLevel {
  final String name;
  final int level;

  const BusinessExpertiseLevel({required this.name, required this.level});

  factory BusinessExpertiseLevel.fromJson(Map<String, dynamic> json) {
    return BusinessExpertiseLevel(
      name: json['name'] as String,
      level: json['level'] as int,
    );
  }
}

class TechnologyStack {
  final List<String> frontend;
  final List<String> backend;
  final List<String> cms;
  final List<String> database;
  final List<String> projectManagement;
  final List<String> cloud;

  const TechnologyStack({
    this.frontend = const [],
    this.backend = const [],
    this.cms = const [],
    this.database = const [],
    this.projectManagement = const [],
    this.cloud = const [],
  });

  factory TechnologyStack.fromJson(Map<String, dynamic> json) {
    return TechnologyStack(
      frontend: (json['frontend'] as List?)?.cast<String>() ?? const [],
      backend: (json['backend'] as List?)?.cast<String>() ?? const [],
      cms: (json['cms'] as List?)?.cast<String>() ?? const [],
      database: (json['database'] as List?)?.cast<String>() ?? const [],
      projectManagement:
      (json['projectManagement'] as List?)?.cast<String>() ?? const [],
      cloud: (json['cloud'] as List?)?.cast<String>() ?? const [],
    );
  }

  List<String> get all => {
    ...frontend,
    ...backend,
    ...cms,
    ...database,
    ...projectManagement,
    ...cloud,
  }.toList();
}

class PriceRange {
  final num min;
  final num max;
  final String currency;

  const PriceRange({required this.min, required this.max, this.currency = 'EUR'});

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] as num?) ?? 0,
      max: (json['max'] as num?) ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
    );
  }
}

class DailyRateRange {
  final num min;
  final num max;

  const DailyRateRange({required this.min, required this.max});

  factory DailyRateRange.fromJson(Map<String, dynamic> json) {
    return DailyRateRange(
      min: (json['min'] as num?) ?? 0,
      max: (json['max'] as num?) ?? 0,
    );
  }
}

class DailyRatePricing {
  final DailyRateRange dailyRate;

  const DailyRatePricing({required this.dailyRate});

  factory DailyRatePricing.fromJson(Map<String, dynamic> json) {
    return DailyRatePricing(
      dailyRate: DailyRateRange.fromJson(json['dailyRate'] as Map<String, dynamic>),
    );
  }
}

class BusinessPricing {
  final PriceRange audit;
  final DailyRatePricing consulting;
  final DailyRatePricing amoa;
  final DailyRatePricing projectManagement;
  final Map<String, num> flutterApplication;
  final Map<String, num> maintenance;

  const BusinessPricing({
    required this.audit,
    required this.consulting,
    required this.amoa,
    required this.projectManagement,
    required this.flutterApplication,
    required this.maintenance,
  });

  factory BusinessPricing.fromJson(Map<String, dynamic> json) {
    return BusinessPricing(
      audit: PriceRange.fromJson(json['audit'] as Map<String, dynamic>),
      consulting:
      DailyRatePricing.fromJson(json['consulting'] as Map<String, dynamic>),
      amoa: DailyRatePricing.fromJson(json['amoa'] as Map<String, dynamic>),
      projectManagement: DailyRatePricing.fromJson(
          json['projectManagement'] as Map<String, dynamic>),
      flutterApplication:
      Map<String, num>.from(json['flutterApplication'] as Map),
      maintenance: Map<String, num>.from(json['maintenance'] as Map),
    );
  }
}

class BusinessModelSplit {
  final num consulting;
  final num development;
  final num maintenance;
  final num training;
  final num audit;

  const BusinessModelSplit({
    required this.consulting,
    required this.development,
    required this.maintenance,
    required this.training,
    required this.audit,
  });

  factory BusinessModelSplit.fromJson(Map<String, dynamic> json) {
    return BusinessModelSplit(
      consulting: (json['consulting'] as num?) ?? 0,
      development: (json['development'] as num?) ?? 0,
      maintenance: (json['maintenance'] as num?) ?? 0,
      training: (json['training'] as num?) ?? 0,
      audit: (json['audit'] as num?) ?? 0,
    );
  }

  /// Répartition prête à afficher (ex: dans un graphique en secteurs).
  List<MapEntry<String, num>> get breakdown => [
    MapEntry('Conseil', consulting),
    MapEntry('Développement', development),
    MapEntry('Maintenance', maintenance),
    MapEntry('Formation', training),
    MapEntry('Audit', audit),
  ];
}

class RoadmapMilestone {
  final int year;
  final String goal;
  final num revenue;

  const RoadmapMilestone({
    required this.year,
    required this.goal,
    required this.revenue,
  });

  factory RoadmapMilestone.fromJson(Map<String, dynamic> json) {
    return RoadmapMilestone(
      year: json['year'] as int,
      goal: json['goal'] as String,
      revenue: (json['revenue'] as num?) ?? 0,
    );
  }
}

class BusinessPlan {
  final String title;
  final String subtitle;
  final String version;
  final TitledContent executiveSummary;
  final TitledContent vision;
  final TitledContent mission;
  final List<BusinessValue> values;
  final BusinessPositioning positioning;
  final BusinessMarket market;
  final List<BusinessPlanService> services;
  final List<String> clients;
  final List<BusinessExpertiseLevel> expertise;
  final TechnologyStack technologies;
  final BusinessPricing pricing;
  final BusinessModelSplit businessModel;
  final List<RoadmapMilestone> roadmap;
  final List<String> competitiveAdvantages;
  final TitledContent longTermVision;

  const BusinessPlan({
    required this.title,
    required this.subtitle,
    required this.version,
    required this.executiveSummary,
    required this.vision,
    required this.mission,
    required this.values,
    required this.positioning,
    required this.market,
    required this.services,
    required this.clients,
    required this.expertise,
    required this.technologies,
    required this.pricing,
    required this.businessModel,
    required this.roadmap,
    required this.competitiveAdvantages,
    required this.longTermVision,
  });

  /// Le JSON racine a la forme `{ "businessPlan": { ... } }`.
  factory BusinessPlan.fromJson(Map<String, dynamic> root) {
    final json = root['businessPlan'] as Map<String, dynamic>;

    return BusinessPlan(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      version: json['version'] as String? ?? '1.0.0',
      executiveSummary:
      TitledContent.fromJson(json['executiveSummary'] as Map<String, dynamic>),
      vision: TitledContent.fromJson(json['vision'] as Map<String, dynamic>),
      mission: TitledContent.fromJson(json['mission'] as Map<String, dynamic>),
      values: (json['values'] as List)
          .map((v) => BusinessValue.fromJson(v as Map<String, dynamic>))
          .toList(),
      positioning:
      BusinessPositioning.fromJson(json['positioning'] as Map<String, dynamic>),
      market: BusinessMarket.fromJson(json['market'] as Map<String, dynamic>),
      services: (json['services'] as List)
          .map((s) => BusinessPlanService.fromJson(s as Map<String, dynamic>))
          .toList(),
      clients: (json['clients'] as List?)?.cast<String>() ?? const [],
      expertise: (json['expertise'] as List)
          .map((e) => BusinessExpertiseLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      technologies:
      TechnologyStack.fromJson(json['technologies'] as Map<String, dynamic>),
      pricing: BusinessPricing.fromJson(json['pricing'] as Map<String, dynamic>),
      businessModel:
      BusinessModelSplit.fromJson(json['businessModel'] as Map<String, dynamic>),
      roadmap: (json['roadmap'] as List)
          .map((r) => RoadmapMilestone.fromJson(r as Map<String, dynamic>))
          .toList(),
      competitiveAdvantages:
      (json['competitiveAdvantages'] as List?)?.cast<String>() ?? const [],
      longTermVision:
      TitledContent.fromJson(json['longTermVision'] as Map<String, dynamic>),
    );
  }

  /// Retrouve un service du business plan par son id
  /// (`audit`, `amoa`, `project`, `flutter`, `transformation`, `ai`, `training`).
  BusinessPlanService? serviceById(String id) {
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }
}