import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../affichage/screen_size_detector.dart';

class ResponsiveConstants {
  final ResponsiveInfo info;

  const ResponsiveConstants(this.info);

  // 📏 FONT SIZES
  double get displayLarge => _scale(48, 36, 32, 28, 24);
  double get displayMedium => _scale(40, 32, 28, 24, 20);
  double get displaySmall => _scale(32, 28, 24, 20, 18);

  double get headlineLarge => _scale(32, 28, 24, 22, 20);
  double get headlineMedium => _scale(28, 24, 22, 20, 18);
  double get headlineSmall => _scale(24, 22, 20, 18, 16);

  double get titleLarge => _scale(22, 20, 18, 16, 14);
  double get titleMedium => _scale(18, 16, 15, 14, 13);
  double get titleSmall => _scale(16, 15, 14, 13, 12);

  double get bodyLarge => _scale(16, 15, 14, 13, 12);
  double get bodyMedium => _scale(14, 13, 13, 12, 11);
  double get bodySmall => _scale(12, 11, 11, 10, 10);

  double get labelLarge => _scale(14, 13, 12, 11, 10);
  double get labelMedium => _scale(12, 11, 11, 10, 9);
  double get labelSmall => _scale(10, 10, 9, 9, 8);

  // 📐 SPACING
  double get spacingXS => _scale(4, 4, 4, 3, 2);
  double get spacingS => _scale(8, 8, 6, 6, 4);
  double get spacingM => _scale(16, 12, 12, 10, 8);
  double get spacingL => _scale(24, 20, 18, 16, 12);
  double get spacingXL => _scale(32, 28, 24, 20, 16);
  double get spacingXXL => _scale(48, 40, 32, 28, 20);

  // 🖼️ ICON SIZES
  double get iconXS => _scale(16, 14, 12, 12, 10);
  double get iconS => _scale(20, 18, 16, 14, 12);
  double get iconM => _scale(24, 22, 20, 18, 16);
  double get iconL => _scale(32, 28, 24, 22, 20);
  double get iconXL => _scale(48, 40, 36, 32, 28);

  // 🎨 BORDER RADIUS
  double get radiusS => _scale(8, 8, 6, 6, 4);
  double get radiusM => _scale(12, 10, 8, 8, 6);
  double get radiusL => _scale(16, 14, 12, 10, 8);
  double get radiusXL => _scale(24, 20, 16, 14, 12);

  // 📦 CARD SIZES
  double get cardPadding => _scale(24, 20, 16, 12, 8);
  double get cardElevation => _scale(8, 6, 4, 3, 2);

  // 🖱️ BUTTON SIZES
  double get buttonHeight => _scale(56, 50, 44, 40, 36);
  double get buttonPaddingH => _scale(32, 28, 24, 20, 16);
  double get buttonPaddingV => _scale(16, 14, 12, 10, 8);

  // 📱 IMAGE SIZES
  double get avatarS => _scale(40, 36, 32, 28, 24);
  double get avatarM => _scale(80, 70, 60, 50, 40);
  double get avatarL => _scale(120, 100, 80, 70, 60);
  double get avatarXL => _scale(160, 140, 120, 100, 80);

  // 🔢 Helper privé
  double _scale(
    double largeDesktop,
    double desktop,
    double tablet,
    double mobile,
    double watch,
  ) {
    return switch (info.type) {
      DeviceType.largeDesktop => largeDesktop,
      DeviceType.desktop => desktop,
      DeviceType.tablet => tablet,
      DeviceType.mobile => mobile,
      DeviceType.watch => watch,
    };
  }

  // 🎯 Getters de convenance
  bool get isTiny => info.isWatch;
  bool get isSmall => info.isMobile;
  bool get isMedium => info.isTablet;
  bool get isLarge => info.isDesktop;
  bool get isXLarge => info.isLargeDesktop;
}

// 🎁 Provider
final responsiveConstantsProvider = Provider<ResponsiveConstants>((ref) {
  final info = ref.watch(responsiveInfoProvider);
  return ResponsiveConstants(info);
});
