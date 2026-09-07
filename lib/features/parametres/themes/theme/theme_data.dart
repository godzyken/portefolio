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
      AppThemeMode.custom => Brightness.dark, // Par défaut dark pour custom
    };

    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: neutralColor,
      tertiary: tertiaryColor,
      // Couleurs de surface additionnelles
      surfaceContainerHighest: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
      surfaceContainer: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      surfaceContainerLow: isDark ? const Color(0xFF151515) : const Color(0xFFFAFAFA),
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
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : neutralColor,
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
        surfaceTintColor: primaryColor.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // NavigationBar moderne
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 8,
        height: 70,
        indicatorColor: primaryColor.withValues(alpha: 0.15),
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
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 28);
          }
          return IconThemeData(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 24,
          );
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withValues(alpha: 0.12);
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
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
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
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),

      // Icônes
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
      splashColor: primaryColor.withValues(alpha: 0.12),
      highlightColor: primaryColor.withValues(alpha: 0.08),
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

  // Fallback = Multiverse
  static const fallback = BasicTheme(
    primaryColorValue: 0xFF00E5FF,
    tertiaryColorValue: 0xFF9C27FF,
    neutralColorValue: 0xFF000000,
    mode: AppThemeMode.dark,
    name: 'Multiverse',
    emoji: '🌌',
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
  // --- THÈMES CLAIRS ---
  const BasicTheme(
    name: 'Pure White',
    emoji: '⚪',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF2196F3, // Bleu Material
    tertiaryColorValue: 0xFFE3F2FD,
    neutralColorValue: 0xFFFFFFFF, // Blanc pur
  ),
  const BasicTheme(
    name: 'Soft Light',
    emoji: '☁️',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF009688, // Teal
    tertiaryColorValue: 0xFFF1F8E9,
    neutralColorValue: 0xFFF8F9FA, // Gris très clair
  ),
  const BasicTheme(
    name: 'Solarized Light',
    emoji: '☀️',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFFE65100, // Orange profond
    tertiaryColorValue: 0xFFEEE8D5,
    neutralColorValue: 0xFFFDF6E3, // Crème Solarized
  ),
  const BasicTheme(
    name: 'Arctic',
    emoji: '❄️',
    mode: AppThemeMode.light,
    primaryColorValue: 0xFF3F51B5, // Indigo
    tertiaryColorValue: 0xFFE1F5FE,
    neutralColorValue: 0xFFF0F7FF, // Bleu arctique
  ),

  // --- THÈMES SOMBRES ---
  const BasicTheme(
    name: 'Professional Dark',
    emoji: '💼',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00D9FF, // Cyan électrique
    tertiaryColorValue: 0xFF000000, // Noir pur
    neutralColorValue: 0xFF000000, // Noir pur
  ),

  // Thème Pure Black
  const BasicTheme(
    name: 'Pure Black',
    emoji: '⬛',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00E5FF, // Cyan clair
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Midnight OLED
  const BasicTheme(
    name: 'Midnight OLED',
    emoji: '🌙',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF3D5AFE, // Bleu indigo
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Noir/Violet
  const BasicTheme(
    name: 'Purple Black',
    emoji: '🔮',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFFBB86FC, // Violet clair
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Noir/Vert
  const BasicTheme(
    name: 'Emerald Black',
    emoji: '💎',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00E676, // Vert émeraude
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Matrix (noir pur)
  const BasicTheme(
    name: 'Matrix OLED',
    emoji: '🖥️',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00FF41, // Vert Matrix
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Dark Grey (si noir trop intense)
  const BasicTheme(
    name: 'Dark Grey',
    emoji: '🌑',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00D9FF,
    tertiaryColorValue: 0xFF0A0A0A, // Gris très sombre
    neutralColorValue: 0xFF050505,
  ),

  // Thème System
  const BasicTheme(
    name: 'System',
    emoji: '⚙️',
    mode: AppThemeMode.system,
    primaryColorValue: 0xFF2196F3,
    tertiaryColorValue: 0xFF000000,
    neutralColorValue: 0xFF000000,
  ),

  // Thème Multivers Principal (Cyan/Violet)
  const BasicTheme(
    name: 'Multiverse',
    emoji: '🌌',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00E5FF, // Cyan néon
    tertiaryColorValue: 0xFF9C27FF, // Violet néon
    neutralColorValue: 0xFF000000, // Noir spatial pur
  ),

  // Thème Galaxie (Violet/Rose)
  const BasicTheme(
    name: 'Galaxy',
    emoji: '🪐',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFFBB86FC, // Violet pastel
    tertiaryColorValue: 0xFFFF4081, // Rose néon
    neutralColorValue: 0xFF000000,
  ),

  // Thème Nebula (Bleu/Violet)
  const BasicTheme(
    name: 'Nebula',
    emoji: '✨',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF536DFE, // Bleu indigo électrique
    tertiaryColorValue: 0xFFAB47BC, // Violet profond
    neutralColorValue: 0xFF000000,
  ),

  // Thème Quantum (Cyan/Vert)
  const BasicTheme(
    name: 'Quantum',
    emoji: '⚛️',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00FFF7, // Cyan fluo
    tertiaryColorValue: 0xFF00E676, // Vert néon
    neutralColorValue: 0xFF000000,
  ),

  // Thème Black Hole (Violet sombre)
  const BasicTheme(
    name: 'Black Hole',
    emoji: '⚫',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF7C4DFF, // Violet intense
    tertiaryColorValue: 0xFF9C27B0, // Violet Material
    neutralColorValue: 0xFF000000,
  ),

  // Thème Cosmic (Orange/Rose)
  const BasicTheme(
    name: 'Cosmic',
    emoji: '🔥',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFFFF6E40, // Orange cosmique
    tertiaryColorValue: 0xFFE91E63, // Rose vibrant
    neutralColorValue: 0xFF000000,
  ),

  // Thème Aurora (Vert/Bleu)
  const BasicTheme(
    name: 'Aurora',
    emoji: '🌠',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFF00E676, // Vert aurore
    tertiaryColorValue: 0xFF00B8D4, // Bleu glacier
    neutralColorValue: 0xFF000000,
  ),

  // Thème Void (Minimaliste noir/blanc)
  const BasicTheme(
    name: 'Void',
    emoji: '⬛',
    mode: AppThemeMode.dark,
    primaryColorValue: 0xFFFFFFFF, // Blanc pur
    tertiaryColorValue: 0xFF616161, // Gris neutre
    neutralColorValue: 0xFF000000,
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
