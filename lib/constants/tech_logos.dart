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
  final n = name
      .toLowerCase()
      .trim()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll('.', '');
  switch (n) {
    case 'esp8266':
    case 'esp32':
    case 'nodemcu':
    case 'iot':
    case 'sensor':
    case 'hardware':
      return Icons.memory;
    case 'lan':
    case 'network':
    case 'wifi':
    case 'router':
      return Icons.router;
    case 'offlinesync':
    case 'offline':
    case 'sync':
      return Icons.sync;
    case 'education':
    case 'school':
    case 'campus':
      return Icons.school;
    case 'phone':
    case 'mobile':
    case 'smartphone':
      return Icons.phone_android;
    case 'tablet':
      return Icons.tablet_mac;
    case 'desktop':
      return Icons.desktop_windows;
    case 'design':
    case 'ui':
    case 'ux':
    case 'uxui':
      return Icons.design_services;
    case 'cloud':
    case 'aws':
      return Icons.cloud;
    case 'web':
    case 'internet':
      return Icons.web;
    case 'code':
    case 'development':
    case 'flutter':
    case 'dart':
      return Icons.code;
    case 'database':
    case 'sql':
    case 'sqlite':
    case 'hive':
    case 'storage':
      return Icons.storage;
    case 'api':
    case 'rest':
      return Icons.api;
    case 'security':
    case 'aes':
    case 'auth':
      return Icons.security;
    case 'support':
    case 'maintenance':
      return Icons.build;
    case 'management':
    case 'amoa':
    case 'digitalisation':
    case 'transformationdigitale':
      return Icons.business_center;
    case 'vr':
    case 'ar':
    case '3d':
      return Icons.view_in_ar;
    case 'sport':
    case 'football':
    case 'efoot':
    case 'soccer':
      return Icons.sports_soccer;
    case 'music':
    case 'audio':
    case 'logicpro':
      return Icons.music_note;
    case 'ecommerce':
    case 'shop':
    case 'boutique':
      return Icons.shopping_cart;
    default:
      return Icons.extension;
  }
}
