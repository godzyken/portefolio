import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final List<String> features;
  final IconData icon;
  final String? imageUrl;
  final ServiceCategory category;
  final int priority;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.features,
    required this.icon,
    this.imageUrl,
    this.category = ServiceCategory.development,
    this.priority = 0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // Support des deux formats: "imageUrl" et "image"
    final imageUrl = json['imageUrl'] as String? ?? json['image'] as String?;

    developer.log('📦 Parsing service: ${json['title']}');
    developer.log('🖼️ Image URL: $imageUrl');

    return Service(
      id: json['id'] as String? ??
          json['title'].toString().toLowerCase().replaceAll(' ', '_'),
      title: json['title'] as String,
      description: json['description'] as String,
      features: (json['features'] as List?)?.cast<String>() ?? [],
      icon: _getIconFromName(json['icon'] as String? ?? 'extension'),
      imageUrl: imageUrl,
      category: _getCategoryFromString(json['category'] as String?),
      priority: json['priority'] as int? ?? 0,
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
    };
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
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'phone':
      case 'mobile':
        return Icons.phone_android;
      case 'design':
      case 'ui':
      case 'ux':
        return Icons.design_services;
      case 'cloud':
        return Icons.cloud;
      case 'web':
      case 'internet':
        return Icons.web;
      case 'code':
      case 'development':
        return Icons.code;
      case 'database':
        return Icons.storage;
      case 'api':
        return Icons.api;
      case 'security':
        return Icons.security;
      case 'support':
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.extension;
    }
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

/// Services par défaut (fallback)
final List<Service> defaultServices = [
  Service(
    id: 'mobile-dev',
    title: 'Développement Mobile',
    description: 'Applications Flutter cross-platform pour iOS et Android',
    features: ['iOS', 'Android', 'Flutter', 'React Native'],
    icon: Icons.phone_android,
    imageUrl:
        'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
    category: ServiceCategory.mobile,
    priority: 1,
  ),
  Service(
    id: 'web-dev',
    title: 'Développement Web',
    description: 'Sites web et applications web modernes',
    features: ['Angular', 'React', 'Vue.js', 'Node.js'],
    icon: Icons.web,
    imageUrl: 'https://techpearl.com/wp-content/uploads/2021/11/Ionic-App.svg',
    category: ServiceCategory.web,
    priority: 2,
  ),
  Service(
    id: 'cloud-solutions',
    title: 'Solutions Cloud',
    description: 'Architecture et déploiement cloud',
    features: ['AWS', 'Firebase', 'Docker', 'CI/CD'],
    icon: Icons.cloud,
    imageUrl:
        'https://www.tatvasoft.com/outsourcing/wp-content/uploads/2023/06/Angular-Architecture.jpg',
    category: ServiceCategory.cloud,
    priority: 3,
  ),
  Service(
    id: 'support',
    title: 'Support & Maintenance',
    description: 'Support technique et maintenance continue',
    features: ['24/7', 'Monitoring', 'Updates', 'Bug fixes'],
    icon: Icons.build,
    imageUrl: 'assets/images/transformation-digitale.jpg',
    category: ServiceCategory.support,
    priority: 4,
  ),
];

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
