import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

class ProjectSection {
  final String id;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext, ResponsiveInfo) builder;
  final bool isAvailable;

  const ProjectSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.builder,
    this.isAvailable = true,
  });
}
