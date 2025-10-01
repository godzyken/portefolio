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

  // Ajoutez cette méthode améliorée dans la classe BasicTheme
// Remplacez la méthode toThemeData() existante :

  ThemeData toThemeData() {
    final brightness = switch (mode) {
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
      AppThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
      AppThemeMode.custom => Brightness.dark, // Par défaut dark pour custom
    };

    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: neutralColor,
      tertiary: tertiaryColor,
      // Couleurs de surface additionnelles pour dark mode
      surfaceContainerHighest: isDark ? const Color(0xFF2A2A2A) : null,
      surfaceContainer: isDark ? const Color(0xFF1E1E1E) : null,
      surfaceContainerLow: isDark ? const Color(0xFF151515) : null,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // AppBar moderne
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),

      // Cards élégantes
      cardTheme: CardThemeData(
        elevation: isDark ? 4 : 2,
        color: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        surfaceTintColor: primaryColor.withAlpha((255 * 0.05).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // NavigationBar moderne
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 8,
        height: 70,
        indicatorColor: primaryColor.withAlpha((255 * 0.15).toInt()),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            );
          }
          return TextStyle(
            color: colorScheme.onSurface.withAlpha((255 * 0.6).toInt()),
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 28);
          }
          return IconThemeData(
            color: colorScheme.onSurface.withAlpha((255 * 0.6).toInt()),
            size: 24,
          );
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withAlpha((255 * 0.12).toInt());
          }
          return null;
        }),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ElevatedButton moderne
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton subtil
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // InputDecoration moderne
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withAlpha((255 * 0.05).toInt())
            : Colors.grey.withAlpha((255 * 0.1).toInt()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Dividers subtils
      dividerTheme: DividerThemeData(
        color: colorScheme.onSurface.withAlpha((255 * 0.1).toInt()),
        thickness: 1,
        space: 1,
      ),

      // Icônes
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withAlpha((255 * 0.7).toInt()),
        size: 24,
      ),

      // Typographie
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          letterSpacing: 0.25,
        ),
      ),

      // Scaffolds
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0A0A0A) : colorScheme.surface,

      // Splash et highlight
      splashColor: primaryColor.withAlpha((255 * 0.12).toInt()),
      highlightColor: primaryColor.withAlpha((255 * 0.08).toInt()),
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
    primaryColorValue: 0xFF00D9FF, // Cyan
    tertiaryColorValue: 0xFF1A1A1A,
    neutralColorValue: 0xFF0A0A0A,
    mode: AppThemeMode.dark,
    name: 'Professional Dark',
    emoji: '💼',
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
  // Thème Pro Dark (recommandé)
  const BasicTheme(
    name: 'Professional Dark',
    emoji: '💼',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00D9FF, // Cyan électrique
    tertiaryColorValue: 0xFF1A1A1A, // Presque noir
    neutralColorValue: 0xFF0A0A0A, // Noir profond
  ),

  // Thème Midnight Blue
  const BasicTheme(
    name: 'Midnight Blue',
    emoji: '🌙',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF3D5AFE, // Bleu indigo vibrant
    tertiaryColorValue: 0xFF121212,
    neutralColorValue: 0xFF0D0D0D,
  ),

  // Thème Purple Haze
  const BasicTheme(
    name: 'Purple Haze',
    emoji: '🔮',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF9C27B0, // Violet
    tertiaryColorValue: 0xFF1C1C1E,
    neutralColorValue: 0xFF0F0F0F,
  ),

  // Thème Emerald Night
  const BasicTheme(
    name: 'Emerald Night',
    emoji: '💎',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00E676, // Vert émeraude
    tertiaryColorValue: 0xFF141414,
    neutralColorValue: 0xFF0A0A0A,
  ),

  // Thème Amber Dark
  const BasicTheme(
    name: 'Amber Dark',
    emoji: '⚡',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFFFFB300, // Orange/Ambre
    tertiaryColorValue: 0xFF181818,
    neutralColorValue: 0xFF0C0C0C,
  ),

  // Thème Matrix (pour les devs)
  const BasicTheme(
    name: 'Matrix',
    emoji: '🖥️',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00FF41, // Vert Matrix
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Minimal Light (si besoin de clair)
  const BasicTheme(
    name: 'Minimal Light',
    emoji: '☀️',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF1976D2,
    tertiaryColorValue: 0xFFF5F5F5,
    neutralColorValue: 0xFFFFFFFF,
  ),

  // Thème System (s'adapte)
  const BasicTheme(
    name: 'System',
    emoji: '⚙️',
    mode: AppThemeMode.system,
    primaryColorValue: 0xFF2196F3,
    tertiaryColorValue: 0xFF1E1E1E,
    neutralColorValue: 0xFF121212,
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
