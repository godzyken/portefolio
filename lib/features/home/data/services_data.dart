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
    return Service(
      title: json['title'],
      description: json['description'],
      features: (json['features'] as List?)?.cast<String>() ?? [],
      icon: _getIconFromName(json['icon']),
      imageUrl: json['imageUrl'],
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name) {
      case 'phone':
        return Icons.phone_android;
      case 'design':
        return Icons.design_services;
      case 'cloud':
        return Icons.cloud;
      case 'web':
        return Icons.web_stories;
      default:
        return Icons.extension;
    }
  }
}
