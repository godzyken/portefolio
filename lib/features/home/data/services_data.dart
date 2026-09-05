import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../constants/tech_logos.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final List<String> features;
  final IconData icon;
  final String? imageUrl;
  final ServiceCategory category;
  final int priority;

  /// Prix de base (ex: à partir de 500€). Null = pas de prix fixe (sur devis).
  final double? basePrice;

  /// Unité affichée à côté du prix (ex: "€", "à partir de €", "€/mois").
  final String priceUnit;

  /// Précision libre affichée sous le prix (ex: fourchette de tarifs).
  final String? priceNote;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.features,
    required this.icon,
    this.imageUrl,
    this.category = ServiceCategory.development,
    this.priority = 0,
    this.basePrice,
    this.priceUnit = 'sur devis',
    this.priceNote,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Support des formats: "imageUrl" (JSON local) et "image"/"image_url" (Supabase)
    final imageUrl = json['imageUrl'] as String? ??
        json['image'] as String? ??
        json['image_url'] as String?;

    developer.log('📦 Parsing service: ${json['title']}');
    developer.log('🖼️ Image URL: $imageUrl');

    return Service(
      id: json['id'] as String? ??
          json['title'].toString().toLowerCase().replaceAll(' ', '_'),
      title: json['title'] as String,
      description: json['description'] as String,
      features: (json['features'] as List?)?.cast<String>() ?? [],
      icon: getIconFromName(json['icon'] as String? ?? 'extension'),
      imageUrl: imageUrl,
      category: _getCategoryFromString(json['category'] as String?),
      priority: json['priority'] as int? ?? 0,
      basePrice: (json['basePrice'] ?? json['base_price']) == null
          ? null
          : ((json['basePrice'] ?? json['base_price']) as num).toDouble(),
      priceUnit:
          (json['priceUnit'] ?? json['price_unit']) as String? ?? 'sur devis',
      priceNote: (json['priceNote'] ?? json['price_note']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'features': features,
      'icon': _getIconName(icon),
      'imageUrl': imageUrl,
      'category': category.name,
      'priority': priority,
      'basePrice': basePrice,
      'priceUnit': priceUnit,
      'priceNote': priceNote,
    };
  }

  /// Libellé de prix prêt à afficher (ex: "à partir de 500 €").
  String get priceLabel {
    if (basePrice == null) return priceUnit; // ex: "sur devis"
    final formatted = basePrice! % 1 == 0
        ? basePrice!.toStringAsFixed(0)
        : basePrice!.toStringAsFixed(2);
    if (priceUnit.contains('€')) {
      return priceUnit.replaceFirst('€', '$formatted €');
    }
    return '$formatted $priceUnit';
  }

  /// URL d'image nettoyée
  String? get cleanedImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    String cleaned = imageUrl!;

    // Nettoyer "assets/http..." -> "http..."
    if (cleaned.contains('assets/http')) {
      final httpIndex = cleaned.indexOf('http');
      if (httpIndex != -1) {
        cleaned = cleaned.substring(httpIndex);
      }
    }

    // Décoder les URLs encodées
    if (cleaned.contains('%')) {
      try {
        cleaned = Uri.decodeFull(cleaned);
      } catch (e) {
        developer.log('⚠️ Erreur décodage URL: $cleaned', error: e);
      }
    }

    return cleaned;
  }

  bool get isNetworkImage => cleanedImageUrl?.startsWith('http') ?? false;
  bool get isAssetImage {
    final url = cleanedImageUrl;
    return url != null && !url.startsWith('http');
  }

  bool get hasValidImage =>
      cleanedImageUrl != null && cleanedImageUrl!.isNotEmpty;

  Service copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? features,
    IconData? icon,
    String? imageUrl,
    ServiceCategory? category,
    int? priority,
    double? basePrice,
    String? priceUnit,
    String? priceNote,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      features: features ?? this.features,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      basePrice: basePrice ?? this.basePrice,
      priceUnit: priceUnit ?? this.priceUnit,
      priceNote: priceNote ?? this.priceNote,
    );
  }

  static String _getIconName(IconData icon) {
    if (icon == Icons.phone_android) return 'phone';
    if (icon == Icons.design_services) return 'design';
    if (icon == Icons.cloud) return 'cloud';
    if (icon == Icons.web) return 'web';
    if (icon == Icons.code) return 'code';
    if (icon == Icons.storage) return 'database';
    if (icon == Icons.api) return 'api';
    if (icon == Icons.security) return 'security';
    if (icon == Icons.build) return 'support';
    return 'extension';
  }

  static ServiceCategory _getCategoryFromString(String? category) {
    switch (category?.toLowerCase()) {
      case 'mobile':
        return ServiceCategory.mobile;
      case 'web':
        return ServiceCategory.web;
      case 'cloud':
        return ServiceCategory.cloud;
      case 'design':
        return ServiceCategory.design;
      case 'support':
        return ServiceCategory.support;
      default:
        return ServiceCategory.development;
    }
  }

  @override
  String toString() =>
      'Service(id: $id, title: $title, hasImage: $hasValidImage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Catégories de services
enum ServiceCategory {
  mobile,
  web,
  cloud,
  design,
  support,
  development,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.mobile:
        return 'Mobile';
      case ServiceCategory.web:
        return 'Web';
      case ServiceCategory.cloud:
        return 'Cloud';
      case ServiceCategory.design:
        return 'Design';
      case ServiceCategory.support:
        return 'Support';
      case ServiceCategory.development:
        return 'Développement';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.mobile:
        return Icons.phone_android;
      case ServiceCategory.web:
        return Icons.web;
      case ServiceCategory.cloud:
        return Icons.cloud;
      case ServiceCategory.design:
        return Icons.design_services;
      case ServiceCategory.support:
        return Icons.build;
      case ServiceCategory.development:
        return Icons.code;
    }
  }

  Color get color {
    switch (this) {
      case ServiceCategory.mobile:
        return Colors.blue;
      case ServiceCategory.web:
        return Colors.purple;
      case ServiceCategory.cloud:
        return Colors.cyan;
      case ServiceCategory.design:
        return Colors.pink;
      case ServiceCategory.support:
        return Colors.orange;
      case ServiceCategory.development:
        return Colors.green;
    }
  }
}

/// Modèle pour représenter une compétence technique avec niveau d'expertise
class TechSkill {
  final String name;
  final double level; // 0.0 à 1.0 (ou 0 à 100%)
  final int yearsOfExperience;
  final int projectCount;
  final String category; // 'language', 'framework', 'tool', etc.
  final String? icon; // Nom de l'icône ou chemin logo

  const TechSkill({
    required this.name,
    required this.level,
    required this.yearsOfExperience,
    required this.projectCount,
    required this.category,
    this.icon,
  });

  /// Niveau en pourcentage
  int get levelPercent => (level * 100).round();

  /// Label du niveau d'expertise
  String get expertiseLabel {
    if (level >= 0.9) return 'Expert';
    if (level >= 0.7) return 'Avancé';
    if (level >= 0.5) return 'Intermédiaire';
    if (level >= 0.3) return 'Débutant avancé';
    return 'Débutant';
  }

  factory TechSkill.fromJson(Map<String, dynamic> json) {
    return TechSkill(
      name: json['name'] as String,
      level: (json['level'] as num).toDouble(),
      yearsOfExperience: json['yearsOfExperience'] as int,
      projectCount: json['projectCount'] as int,
      category: json['category'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'yearsOfExperience': yearsOfExperience,
      'projectCount': projectCount,
      'category': category,
      'icon': icon,
    };
  }
}

/// Statistiques d'expertise pour un service
class ServiceExpertise {
  final String serviceId;
  final List<TechSkill> skills;
  final int totalProjects;
  final int totalYearsExperience;
  final double averageLevel;

  const ServiceExpertise({
    required this.serviceId,
    required this.skills,
    required this.totalProjects,
    required this.totalYearsExperience,
    required this.averageLevel,
  });

  factory ServiceExpertise.fromJson(Map<String, dynamic> json) {
    final skillsList = (json['skills'] as List)
        .map((e) => TechSkill.fromJson(e as Map<String, dynamic>))
        .toList();

    return ServiceExpertise(
      serviceId: json['serviceId'] as String,
      skills: skillsList,
      totalProjects: json['totalProjects'] as int,
      totalYearsExperience: json['totalYearsExperience'] as int,
      averageLevel: (json['averageLevel'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'skills': skills.map((s) => s.toJson()).toList(),
      'totalProjects': totalProjects,
      'totalYearsExperience': totalYearsExperience,
      'averageLevel': averageLevel,
    };
  }

  /// Compétences par catégorie
  Map<String, List<TechSkill>> get skillsByCategory {
    final Map<String, List<TechSkill>> result = {};
    for (final skill in skills) {
      result.putIfAbsent(skill.category, () => []).add(skill);
    }
    return result;
  }

  /// Top 5 compétences
  List<TechSkill> get topSkills {
    final sorted = List<TechSkill>.from(skills)
      ..sort((a, b) => b.level.compareTo(a.level));
    return sorted.take(5).toList();
  }
}

/// Pack tarifaire (ex: Découverte / Croissance / Premium, ou une offre
/// sur-mesure comme "Offre Essentielle"). Rattaché à un [Service] via
/// [serviceId], mais peut aussi rester autonome (serviceId == null).
class PricingPack {
  final int? id;
  final String? serviceId;
  final String name;
  final double price;
  final String priceUnit;
  final String? description;
  final List<String> features;
  final int priority;
  final bool isFeatured;
  final bool active;

  const PricingPack({
    this.id,
    this.serviceId,
    required this.name,
    required this.price,
    this.priceUnit = '€',
    this.description,
    this.features = const [],
    this.priority = 0,
    this.isFeatured = false,
    this.active = true,
  });

  factory PricingPack.fromJson(Map<String, dynamic> json) {
    return PricingPack(
      id: json['id'] as int?,
      serviceId: json['service_id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      priceUnit: json['price_unit'] as String? ?? '€',
      description: json['description'] as String?,
      features: (json['features'] as List?)?.cast<String>() ?? [],
      priority: json['priority'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
    );
  }

  /// Payload d'écriture pour Supabase (sans id/serviceId gérés à part).
  Map<String, dynamic> toInsertPayload() {
    return {
      if (serviceId != null) 'service_id': serviceId,
      'name': name,
      'price': price,
      'price_unit': priceUnit,
      'description': description,
      'features': features,
      'priority': priority,
      'is_featured': isFeatured,
      'active': active,
    };
  }

  String get priceLabel {
    final formatted =
        price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2);
    return priceUnit == '€' ? '$formatted €' : '$formatted $priceUnit';
  }

  PricingPack copyWith({
    int? id,
    String? serviceId,
    String? name,
    double? price,
    String? priceUnit,
    String? description,
    List<String>? features,
    int? priority,
    bool? isFeatured,
    bool? active,
  }) {
    return PricingPack(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      description: description ?? this.description,
      features: features ?? this.features,
      priority: priority ?? this.priority,
      isFeatured: isFeatured ?? this.isFeatured,
      active: active ?? this.active,
    );
  }
}

/// Une ligne du tableau de comparaison marché (freelance vs agence).
class MarketComparisonRow {
  final String label;
  final String freelanceRange;
  final String agencyRange;

  const MarketComparisonRow({
    required this.label,
    required this.freelanceRange,
    required this.agencyRange,
  });

  factory MarketComparisonRow.fromJson(Map<String, dynamic> json) {
    return MarketComparisonRow(
      label: json['label'] as String? ?? '',
      freelanceRange: json['freelance_range'] as String? ?? '',
      agencyRange: json['agency_range'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'freelance_range': freelanceRange,
        'agency_range': agencyRange,
      };
}

/// Contenu de la page publique "pourquoi ce tarif", par service.
/// Alimente `PricingRationaleScreen`, accessible en cliquant sur le prix.
class PricingRationale {
  final String serviceId;
  final String introText;
  final List<MarketComparisonRow> marketComparison;

  /// {frais_gestion_pct, coefficient_transformation, note}
  final Map<String, dynamic> portageBreakdown;

  /// {title, invoice_ht, base_calcul, remuneration_brute, note} — vide si
  /// aucun exemple n'a été renseigné pour ce service.
  final Map<String, dynamic> anonymizedExample;

  const PricingRationale({
    required this.serviceId,
    required this.introText,
    this.marketComparison = const [],
    this.portageBreakdown = const {},
    this.anonymizedExample = const {},
  });

  bool get hasExample => anonymizedExample.isNotEmpty;

  factory PricingRationale.fromJson(Map<String, dynamic> json) {
    return PricingRationale(
      serviceId: json['service_id'] as String,
      introText: json['intro_text'] as String? ?? '',
      marketComparison: (json['market_comparison'] as List? ?? [])
          .map((e) => MarketComparisonRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      portageBreakdown:
          (json['portage_breakdown'] as Map?)?.cast<String, dynamic>() ?? {},
      anonymizedExample:
          (json['anonymized_example'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  Map<String, dynamic> toUpsertPayload() => {
        'service_id': serviceId,
        'intro_text': introText,
        'market_comparison': marketComparison.map((e) => e.toJson()).toList(),
        'portage_breakdown': portageBreakdown,
        'anonymized_example': anonymizedExample,
      };
}
