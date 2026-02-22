import 'package:flutter/material.dart';

import '../../../../../core/affichage/screen_size_detector.dart';

/// Classe utilitaire pour gérer les tailles et espacements responsive
class ServiceCardHelpers {
  static double getBorderRadius(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  static double getPadding(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  static double getSpacing(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) =>
      info.isWatch || info.isMobile
          ? small
          : info.isTablet
              ? medium
              : large;

  static double getFontSize(
    ResponsiveInfo info, {
    required double small,
    required double medium,
    required double large,
  }) =>
      info.isWatch || info.isMobile
          ? small
          : info.isTablet
              ? medium
              : large;

  static double getIconSize(ResponsiveInfo info) => info.isWatch
      ? 20
      : info.isMobile
          ? 24
          : info.isTablet
              ? 28
              : 32;

  static double getCenterRadius(ResponsiveInfo info) {
    if (info.isWatch) return 15;
    if (info.isMobile) return 20;
    if (info.isTablet) return 25;
    return 30;
  }

  static double getRadius(ResponsiveInfo info) {
    if (info.isWatch) return 35;
    if (info.isMobile) return 50;
    if (info.isTablet) return 55;
    return 60;
  }

  static bool shouldShowTitle(ResponsiveInfo info) {
    return !info.isWatch && !info.isMobile;
  }

  static List<Color> getChartColors() {
    return [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];
  }
}
