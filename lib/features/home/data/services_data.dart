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
      features: json['features'],
      icon: _getIconFromName(json['icon']),
      imageUrl: json['imageUrl'],
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name) {
      case 'phone_android':
        return Icons.phone_android;
      case 'design_services':
        return Icons.design_services;
      case 'cloud':
        return Icons.cloud;
      // Ajoute ici d'autres icônes au besoin
      default:
        return Icons.extension;
    }
  }
}
