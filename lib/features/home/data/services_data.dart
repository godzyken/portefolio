import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class Service {
  final String title;
  final String description;
  final List<String> features;
  final IconData icon;
  final String? imageUrl;

  Service({
    required this.title,
    required this.description,
    required this.features,
    required this.icon,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl'] as String?;

    // 🔍 DEBUG: Log l'URL de l'image
    developer.log('📦 SERVICE: ${json['title']}');
    developer.log('🖼️ IMAGE URL: $imageUrl');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return Service(
      title: json['title'] as String,
      description: json['description'] as String,
      features: (json['features'] as List?)?.cast<String>() ?? [],
      icon: _getIconFromName(json['icon'] as String? ?? 'extension'),
      imageUrl: imageUrl,
    );
  }

  /// Getter pour obtenir l'URL nettoyée de l'image
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

    developer.log('✨ URL nettoyée: $cleaned');
    return cleaned;
  }

  /// Vérifie si l'image est une URL réseau
  bool get isNetworkImage {
    return cleanedImageUrl?.startsWith('http') ?? false;
  }

  /// Vérifie si l'image est un asset local
  bool get isAssetImage {
    final url = cleanedImageUrl;
    return url != null && !url.startsWith('http');
  }

  /// Vérifie si le service a une image valide
  bool get hasValidImage {
    return cleanedImageUrl != null && cleanedImageUrl!.isNotEmpty;
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
      default:
        return Icons.extension;
    }
  }

  @override
  String toString() {
    return 'Service(title: $title, imageUrl: $cleanedImageUrl, hasImage: $hasValidImage)';
  }
}

/// Liste de services par défaut (fallback si le JSON échoue)
final List<Service> defaultServices = [
  Service(
    title: 'Développement Mobile',
    description:
        'Création d\'applications mobiles natives et cross-platform avec Flutter et React Native',
    features: ['iOS', 'Android', 'Flutter', 'React Native'],
    icon: Icons.phone_android,
    imageUrl:
        'https://storage.googleapis.com/cms-storage-bucket/build-more-with-flutter.f399274b364a6194c43d.png',
  ),
  Service(
    title: 'Design UX/UI',
    description: 'Conception d\'interfaces utilisateur modernes et intuitives',
    features: ['Figma', 'Adobe XD', 'Prototypage', 'Design System'],
    icon: Icons.design_services,
    imageUrl:
        'https://cenotia.com/wp-content/uploads/2017/05/transformation-digitale.jpg',
  ),
  Service(
    title: 'Solutions Cloud',
    description: 'Architecture et déploiement d\'applications dans le cloud',
    features: ['AWS', 'Firebase', 'Docker', 'CI/CD'],
    icon: Icons.cloud,
    imageUrl:
        'https://www.tatvasoft.com/outsourcing/wp-content/uploads/2023/06/Angular-Architecture.jpg',
  ),
  Service(
    title: 'Développement Web',
    description: 'Sites web et applications web modernes et performantes',
    features: ['Angular', 'React', 'Vue.js', 'Node.js'],
    icon: Icons.web,
    imageUrl: 'https://techpearl.com/wp-content/uploads/2021/11/Ionic-App.svg',
  ),
];
