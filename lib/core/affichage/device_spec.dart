import 'package:flutter/material.dart';

/// Spécifications pour différents types d'appareils
/// Utilisé dans les visualisations de projets et cartes
class DeviceSpec {
  final Size size;
  final BorderRadius borderRadius;
  final BorderRadius screenRadius;
  final Color bodyColor;
  final Color frameColor;
  final Color accentColor;
  final double frameWidth;
  final double bezelSize;
  final IconData icon;
  final DeviceType type;

  const DeviceSpec({
    required this.size,
    required this.borderRadius,
    required this.screenRadius,
    required this.bodyColor,
    required this.frameColor,
    required this.accentColor,
    required this.frameWidth,
    required this.bezelSize,
    required this.icon,
    required this.type,
  });

  factory DeviceSpec.watch() => const DeviceSpec(
        size: Size(90, 90),
        borderRadius: BorderRadius.all(Radius.circular(22)),
        screenRadius: BorderRadius.all(Radius.circular(18)),
        bodyColor: Color(0xFF1a1a1a),
        frameColor: Color(0xFF0d0d0d),
        accentColor: Color(0xFF00d4ff),
        frameWidth: 4,
        bezelSize: 8,
        icon: Icons.watch,
        type: DeviceType.watch,
      );

  factory DeviceSpec.smartphone() => const DeviceSpec(
        size: Size(110, 220),
        borderRadius: BorderRadius.all(Radius.circular(28)),
        screenRadius: BorderRadius.all(Radius.circular(24)),
        bodyColor: Color(0xFF0a0a0a),
        frameColor: Color(0xFF050505),
        accentColor: Color(0xFF00ff88),
        frameWidth: 3,
        bezelSize: 5,
        icon: Icons.phone_android,
        type: DeviceType.smartphone,
      );

  factory DeviceSpec.tablet() => const DeviceSpec(
        size: Size(160, 220),
        borderRadius: BorderRadius.all(Radius.circular(24)),
        screenRadius: BorderRadius.all(Radius.circular(20)),
        bodyColor: Color(0xFF1f1f1f),
        frameColor: Color(0xFF0f0f0f),
        accentColor: Color(0xFFa855f7),
        frameWidth: 4,
        bezelSize: 10,
        icon: Icons.tablet_android,
        type: DeviceType.tablet,
      );

  factory DeviceSpec.desktop() => const DeviceSpec(
        size: Size(240, 150),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        screenRadius: BorderRadius.all(Radius.circular(12)),
        bodyColor: Color(0xFF2a2a2a),
        frameColor: Color(0xFF0a0a0a),
        accentColor: Color(0xFFfb923c),
        frameWidth: 5,
        bezelSize: 14,
        icon: Icons.computer,
        type: DeviceType.desktop,
      );

  factory DeviceSpec.largeDesktop() => const DeviceSpec(
        size: Size(300, 180),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        screenRadius: BorderRadius.all(Radius.circular(16)),
        bodyColor: Color(0xFF1a1a1a),
        frameColor: Color(0xFF000000),
        accentColor: Color(0xFFef4444),
        frameWidth: 6,
        bezelSize: 16,
        icon: Icons.desktop_windows,
        type: DeviceType.largeDesktop,
      );

  /// Factory pour créer un DeviceSpec basé sur une liste de plateformes
  factory DeviceSpec.fromPlatforms(List<String>? platforms) {
    if (platforms == null || platforms.isEmpty) {
      return DeviceSpec.smartphone();
    }

    final platformsLower = platforms.map((e) => e.toLowerCase()).toList();

    if (platformsLower.contains('watch')) return DeviceSpec.watch();
    if (platformsLower.contains('smartphone') ||
        platformsLower.contains('mobile')) {
      return DeviceSpec.smartphone();
    }
    if (platformsLower.contains('tablet')) return DeviceSpec.tablet();
    if (platformsLower.contains('desktop')) return DeviceSpec.desktop();
    if (platformsLower.contains('largedesktop')) {
      return DeviceSpec.largeDesktop();
    }

    return DeviceSpec.smartphone();
  }

  List<Widget> buildDeviceDetails(dynamic widget) {
    switch (type) {
      case DeviceType.watch:
        return _buildWatchDetails();
      case DeviceType.smartphone:
        return _buildSmartphoneDetails();
      case DeviceType.tablet:
        return _buildTabletDetails();
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return _buildDesktopDetails();
    }
  }

  List<Widget> _buildWatchDetails() {
    return [
      // Bouton latéral
      Positioned(
        right: -4,
        top: size.height * 0.35,
        child: Container(
          width: 10,
          height: 24,
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
        ),
      ),
      // Bouton digital crown
      Positioned(
        bottom: bezelSize + 10,
        left: size.width / 2 - 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.green.shade700.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade800, width: 2),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSmartphoneDetails() {
    return [
      // Encoche supérieure
      Positioned(
        top: 0,
        left: size.width / 2 - 25,
        child: Container(
          width: 50,
          height: bezelSize - 1,
          decoration: BoxDecoration(
            color: frameColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildTabletDetails() {
    return [
      // Caméra frontale
      Positioned(
        top: bezelSize / 2 - 3,
        left: size.width / 2 - 3,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDesktopDetails() {
    final isLarge = type == DeviceType.largeDesktop;
    return [
      // Webcam
      Positioned(
        top: bezelSize / 2 - 2,
        left: size.width / 2 - 3,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
      // Pied du moniteur
      Positioned(
        bottom: -20,
        left: size.width / 2 - (isLarge ? 35 : 25),
        child: Container(
          width: isLarge ? 70 : 50,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      // Base du moniteur
      Positioned(
        bottom: -36,
        left: size.width / 2 - (isLarge ? 20 : 14),
        child: Container(
          width: isLarge ? 40 : 28,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Calcule la taille réelle de l'écran (sans les bordures)
  Size get screenSize => Size(
        size.width - 2 * bezelSize,
        size.height - 2 * bezelSize,
      );

  /// Crée une copie avec les propriétés modifiées
  DeviceSpec copyWith({
    Size? size,
    BorderRadius? borderRadius,
    BorderRadius? screenRadius,
    Color? bodyColor,
    Color? frameColor,
    Color? accentColor,
    double? frameWidth,
    double? bezelSize,
    IconData? icon,
    DeviceType? type,
  }) {
    return DeviceSpec(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      screenRadius: screenRadius ?? this.screenRadius,
      bodyColor: bodyColor ?? this.bodyColor,
      frameColor: frameColor ?? this.frameColor,
      accentColor: accentColor ?? this.accentColor,
      frameWidth: frameWidth ?? this.frameWidth,
      bezelSize: bezelSize ?? this.bezelSize,
      icon: icon ?? this.icon,
      type: type ?? this.type,
    );
  }
}

enum DeviceType {
  watch,
  smartphone,
  tablet,
  desktop,
  largeDesktop,
}
