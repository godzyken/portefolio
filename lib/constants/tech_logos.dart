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
    case 'ios':
    case 'android':
      return Icons.phone_android;
    case 'tablet':
      return Icons.tablet_mac;
    case 'desktop':
    case 'windows':
    case 'macos':
    case 'linux':
      return Icons.desktop_windows;
    case 'design':
    case 'ui':
    case 'ux':
    case 'uxui':
    case 'figma':
    case 'adobe':
      return Icons.design_services;
    case 'cloud':
    case 'aws':
    case 'googlecloud':
    case 'gcp':
      return Icons.cloud;
    case 'web':
    case 'internet':
    case 'html':
    case 'html5':
    case 'css':
    case 'css3':
      return Icons.web;
    case 'code':
    case 'development':
    case 'flutter':
    case 'dart':
    case 'python':
    case 'javascript':
    case 'js':
    case 'typescript':
    case 'ts':
    case 'c':
    case 'cpp':
    case 'cplusplus':
    case 'csharp':
    case 'cs':
      return Icons.code;
    case 'database':
    case 'sql':
    case 'sqlite':
    case 'postgresql':
    case 'mysql':
    case 'mongodb':
    case 'hive':
    case 'storage':
      return Icons.storage;
    case 'api':
    case 'rest':
    case 'graphql':
    case 'openapi':
    case 'websocket':
      return Icons.api;
    case 'security':
    case 'aes':
    case 'auth':
    case 'gdpr':
    case 'rgpd':
      return Icons.security;
    case 'support':
    case 'maintenance':
    case 'bug':
    case 'testing':
      return Icons.build;
    case 'management':
    case 'amoa':
    case 'digitalisation':
    case 'transformationdigitale':
    case 'agile':
    case 'scrum':
      return Icons.business_center;
    case 'vr':
    case 'ar':
    case '3d':
    case 'unity':
    case 'blender':
    case 'sketchup':
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
    case 'prestashop':
    case 'wordpress':
      return Icons.shopping_cart;
    case 'git':
    case 'github':
    case 'gitlab':
    case 'cicd':
    case 'githubactions':
    case 'docker':
    case 'kubernetes':
      return Icons.source;
    case 'riverpod':
    case 'provider':
    case 'bloc':
    case 'statemanagement':
      return Icons.layers;
    default:
      return Icons.extension;
  }
}
