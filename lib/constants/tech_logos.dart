import 'package:flutter/material.dart';

final wakatimeBadges = <String, String>{
  'addi_kichi':
      'https://wakatime.com/badge/user/d44d9645-f329-4729-a92d-c1c4ce039e23/project/341a935e-378f-407b-8da3-493036aa90f7.svg',
  'egote_services_v4':
      'https://wakatime.com/badge/user/d44d9645-f329-4729-a92d-c1c4ce039e23/project/xxxxxxxx-xxxx.svg',
  'egote_services_v2':
      'https://wakatime.com/badge/user/d44d9645-f329-4729-a92d-c1c4ce039e23/project/8e9f1ce9-8b60-4b80-9631-f8516955e6c0.svg',
  // Ajoute d'autres projets ici
};

//https://wakatime.com/badge/user/d44d9645-f329-4729-a92d-c1c4ce039e23/project/8e9f1ce9-8b60-4b80-9631-f8516955e6c0.svg

IconData getIconFromName(String name) {
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
