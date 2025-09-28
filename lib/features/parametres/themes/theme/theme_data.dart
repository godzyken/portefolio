import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_data.g.dart';

@HiveType(typeId: 1)
enum AppThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 2)
class BasicTheme {
  @HiveField(0)
  final int primaryColorValue;
  @HiveField(1)
  final int tertiaryColorValue;
  @HiveField(2)
  final int neutralColorValue;
  @HiveField(3)
  final AppThemeMode mode;
  @HiveField(4)
  final String name;
  @HiveField(5)
  final String? emoji;

  const BasicTheme({
    required this.primaryColorValue,
    required this.tertiaryColorValue,
    required this.neutralColorValue,
    this.mode = AppThemeMode.system,
    this.name = 'Thème par défaut',
    this.emoji,
  });

  Color get primaryColor => Color(primaryColorValue);
  Color get tertiaryColor => Color(tertiaryColorValue);
  Color get neutralColor => Color(neutralColorValue);

  ThemeData toThemeData() {
    final brightness = switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
      AppThemeMode.custom => Brightness.light,
    };

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: neutralColor,
      tertiary: tertiaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      /*      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withAlpha(
          (255 * 0.6).toInt(),
        ),
        showUnselectedLabels: true,
      ),*/
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 10,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: colorScheme.onSurface);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 28);
          }
          return IconThemeData(color: colorScheme.onSurface, size: 24);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withAlpha((255 * 0.6).toInt());
          }
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withAlpha((255 * 0.12).toInt());
          }
          return null;
        }),
      ),
    );
  }

  BasicTheme copyWith({
    Color? primaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
    AppThemeMode? mode,
    TextTheme? textTheme,
  }) {
    return BasicTheme(
      primaryColorValue: primaryColor?.toARGB32() ?? primaryColorValue,
      tertiaryColorValue: tertiaryColor?.toARGB32() ?? tertiaryColorValue,
      neutralColorValue: neutralColor?.toARGB32() ?? neutralColorValue,
      mode: mode ?? this.mode,
    );
  }

  static const fallback = BasicTheme(
    primaryColorValue: 0xFF356859,
    tertiaryColorValue: 0xFFF8A776,
    neutralColorValue: 0xFF7ECA64,
  );

  Map<String, dynamic> toJson() => {
        'primaryColorValue': primaryColorValue,
        'tertiaryColorValue': tertiaryColorValue,
        'neutralColorValue': neutralColorValue,
        'mode': mode.name,
        'name': name,
        'emoji': emoji,
      };

  static BasicTheme fromJson(Map<String, dynamic> json) {
    return BasicTheme(
      primaryColorValue: json['primaryColorValue'] as int,
      tertiaryColorValue: json['tertiaryColorValue'] as int,
      neutralColorValue: json['neutralColorValue'] as int,
      mode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => AppThemeMode.system,
      ),
      name: json['name'] as String? ?? 'Thème chargé',
      emoji: json['emoji'] as String?,
    );
  }
}

final availableThemes = [
  const BasicTheme(
    name: 'Jungle',
    emoji: '🌿',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF356859,
    tertiaryColorValue: 0xFFF8A776,
    neutralColorValue: 0xFF7ECA64,
  ),
  const BasicTheme(
    name: 'Océan',
    emoji: '🌊',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF4A90E2,
    tertiaryColorValue: 0xFFFFC107,
    neutralColorValue: 0xFFE1F5FE,
  ),
  const BasicTheme(
    name: 'Nuit',
    emoji: '🌙',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF212121,
    tertiaryColorValue: 0xFF607D8B,
    neutralColorValue: 0xFF424242,
  ),
];

extension BasicThemeSerialization on BasicTheme {
  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColorValue,
        'tertiaryColor': tertiaryColorValue,
        'neutralColor': neutralColorValue,
        'mode': mode.name,
        'name': name,
        'emoji': emoji,
      };

  static BasicTheme fromJson(Map<String, dynamic> json) {
    return BasicTheme(
      primaryColorValue: json['primaryColor'] as int,
      tertiaryColorValue: json['tertiaryColor'] as int,
      neutralColorValue: json['neutralColor'] as int,
      mode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => AppThemeMode.system,
      ),
      name: json['name'] as String? ?? 'Thème chargé',
      emoji: json['emoji'] as String?,
    );
  }
}
