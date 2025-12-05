import 'package:flutter/material.dart';

class TechIconHelper {
  static const Map<String, IconData> _techIconMap = {
    // Mobile
    'flutter': Icons.phone_android,
    'dart': Icons.phone_android,
    'android': Icons.android,
    'ios': Icons.apple,
    'swift': Icons.apple,
    'kotlin': Icons.android,

    // Web Frontend
    'angular': Icons.web,
    'react': Icons.web,
    'vue': Icons.web,
    'html': Icons.web,
    'css': Icons.web,
    'javascript': Icons.web,
    'typescript': Icons.web,

    // Backend
    'node': Icons.dns,
    'nodejs': Icons.dns,
    'express': Icons.dns,
    'php': Icons.dns,
    'laravel': Icons.dns,
    'python': Icons.dns,
    'java': Icons.dns,
    'c#': Icons.dns,
    'c++': Icons.dns,
    'rust': Icons.dns,
    'go': Icons.dns,

    // Cloud & Infrastructure
    'firebase': Icons.cloud,
    'cloud': Icons.cloud,
    'aws': Icons.cloud,
    'azure': Icons.cloud,
    'gcp': Icons.cloud,
    'ovh': Icons.cloud,

    // Database
    'database': Icons.storage,
    'sql': Icons.storage,
    'mysql': Icons.storage,
    'postgresql': Icons.storage,
    'mongodb': Icons.storage,
    'mongo': Icons.storage,

    // E-commerce
    'prestashop': Icons.shopping_cart,
    'magento': Icons.shopping_cart,
    'woocommerce': Icons.shopping_cart,
    'shopify': Icons.shopping_cart,
    'e-commerce': Icons.shopping_cart,

    // Version Control
    'git': Icons.code_outlined,
    'github': Icons.code_outlined,
    'gitlab': Icons.code_outlined,

    // Design
    'figma': Icons.design_services,
    'photoshop': Icons.image,
    'illustrator': Icons.draw,

    // Mapping
    'sig': Icons.map,
    'gis': Icons.map,
    'maps': Icons.map,
  };

  /// Obtient l'icône pour une technologie donnée
  static IconData getIconForTech(String tech) {
    final techLower = tech.toLowerCase().trim();

    // Recherche exacte
    if (_techIconMap.containsKey(techLower)) {
      return _techIconMap[techLower]!;
    }

    // Recherche partielle
    for (final entry in _techIconMap.entries) {
      if (techLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Icône par défaut
    return Icons.star;
  }

  /// Vérifie si une technologie est liée à la programmation
  static bool isProgrammingTech(String tech) {
    const programmingTags = [
      'dart',
      'flutter',
      'angular',
      'javascript',
      'typescript',
      'java',
      'python',
      'c#',
      'c++',
      'rust',
      'github',
      'git',
      'go',
      'php',
      'swift',
      'kotlin',
      'mysql',
      'prestashop',
      'magento',
      'ovh',
      'html',
      'css',
      'laravel',
      'e-commerce',
      'digital',
      'node',
      'react',
      'vue',
    ];

    final techLower = tech.toLowerCase();
    return programmingTags.any((tag) => techLower.contains(tag));
  }

  /// Obtient la catégorie d'une technologie
  static TechCategory getTechCategory(String tech) {
    final techLower = tech.toLowerCase().trim();

    if (_isMobileTech(techLower)) return TechCategory.mobile;
    if (_isWebTech(techLower)) return TechCategory.web;
    if (_isBackendTech(techLower)) return TechCategory.backend;
    if (_isCloudTech(techLower)) return TechCategory.cloud;
    if (_isDatabaseTech(techLower)) return TechCategory.database;
    if (_isEcommerceTech(techLower)) return TechCategory.ecommerce;
    if (_isDesignTech(techLower)) return TechCategory.design;

    return TechCategory.other;
  }

  static bool _isMobileTech(String tech) {
    return tech.contains('flutter') ||
        tech.contains('dart') ||
        tech.contains('android') ||
        tech.contains('ios') ||
        tech.contains('swift') ||
        tech.contains('kotlin');
  }

  static bool _isWebTech(String tech) {
    return tech.contains('angular') ||
        tech.contains('react') ||
        tech.contains('vue') ||
        tech.contains('html') ||
        tech.contains('css') ||
        tech.contains('javascript') ||
        tech.contains('typescript');
  }

  static bool _isBackendTech(String tech) {
    return tech.contains('node') ||
        tech.contains('express') ||
        tech.contains('php') ||
        tech.contains('laravel') ||
        tech.contains('python') ||
        tech.contains('java') ||
        tech.contains('go') ||
        tech.contains('rust');
  }

  static bool _isCloudTech(String tech) {
    return tech.contains('firebase') ||
        tech.contains('cloud') ||
        tech.contains('aws') ||
        tech.contains('azure') ||
        tech.contains('gcp') ||
        tech.contains('ovh');
  }

  static bool _isDatabaseTech(String tech) {
    return tech.contains('sql') ||
        tech.contains('database') ||
        tech.contains('mongo') ||
        tech.contains('postgres');
  }

  static bool _isEcommerceTech(String tech) {
    return tech.contains('prestashop') ||
        tech.contains('magento') ||
        tech.contains('woocommerce') ||
        tech.contains('shopify') ||
        tech.contains('e-commerce');
  }

  static bool _isDesignTech(String tech) {
    return tech.contains('figma') ||
        tech.contains('photoshop') ||
        tech.contains('illustrator');
  }
}

/// Catégories de technologies
enum TechCategory {
  mobile,
  web,
  backend,
  cloud,
  database,
  ecommerce,
  design,
  other,
}
