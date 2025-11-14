import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';
import 'package:portefolio/features/home/views/widgets/service_expertise_card.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../../../core/ui/widgets/smart_image.dart';

class ServicesCard extends ConsumerWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServicesCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);

    return GestureDetector(
      onTap: onTap ?? () => _showExpertiseDialog(context, ref),
      child: HoverCard(
        id: service.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_getBorderRadius(info)),
          child: SizedBox(
            height: info.isMobile ? 420 : 480,
            child: Column(
              children: [
                // Section supérieure : Image + Badge + Titre
                SizedBox(
                  height: info.isMobile ? 180 : 200,
                  child: _buildTopSection(context, theme, info, ref),
                ),
                const ResponsiveBox(height: 8),
                // Section inférieure : Graphique camembert
                Expanded(
                  child: _buildBottomSection(context, theme, info, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack);
  }

  /// Section supérieure avec image de fond
  Widget _buildTopSection(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
    WidgetRef ref,
  ) {
    final expertise = ref.watch(serviceExpertiseProvider(service.id));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        _buildBackgroundImage(theme),

        // Overlay gradient
        _buildOverlay(),

        // Contenu
        ResponsiveBox(
          padding: EdgeInsets.all(_getPadding(info)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge d'expertise en haut à droite
              if (expertise != null)
                Align(
                  alignment: Alignment.topRight,
                  child: _buildExpertiseBadge(expertise, theme),
                ),

              // Titre et icône en bas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIconBadge(theme, info),
                      ResponsiveBox(
                          width: _getSpacing(info,
                              small: 12, medium: 14, large: 16)),
                      Flexible(
                        fit: FlexFit.tight,
                        child: ResponsiveText.titleMedium(
                          service.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _getFontSize(info,
                                small: 18, medium: 22, large: 24),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  ResponsiveBox(
                      height:
                          _getSpacing(info, small: 8, medium: 10, large: 12)),
                  ResponsiveText.bodySmall(
                    service.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize:
                          _getFontSize(info, small: 12, medium: 13, large: 14),
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Section inférieure avec graphique camembert
  Widget _buildBottomSection(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
    WidgetRef ref,
  ) {
    final expertise = ref.watch(serviceExpertiseProvider(service.id));

    if (expertise == null) {
      return Card(
        color: theme.colorScheme.surface,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Aucune donnée disponible',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // la carte s’adapte au contenu
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technologies & Compétences',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: _getSpacing(info, small: 8, medium: 12, large: 16)),

            // Pie chart + légende
            info.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPieChart(expertise, theme, info),
                      SizedBox(
                          height: _getSpacing(info,
                              small: 8, medium: 12, large: 16)),
                      _buildLegend(expertise, theme, info),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: _buildPieChart(expertise, theme, info)),
                      SizedBox(
                          width: _getSpacing(info,
                              small: 8, medium: 12, large: 16)),
                      Expanded(
                          flex: 2, child: _buildLegend(expertise, theme, info)),
                    ],
                  ),

            SizedBox(
                height: _getSpacing(info, small: 8, medium: 10, large: 12)),
            _buildStats(expertise, theme, info),
          ],
        ),
      ),
    );
  }

  /// Graphique camembert
  Widget _buildPieChart(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final skills = expertise.topSkills.take(5).toList();

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: info.isMobile ? 20 : 30,
        sections: skills.asMap().entries.map((entry) {
          final index = entry.key;
          final skill = entry.value;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: skill.level * 100,
            title: info.isMobile ? '' : '${skill.levelPercent}%',
            radius: 65,
            titleStyle: TextStyle(
              fontSize: info.isMobile ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: ResponsiveBox(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ResponsiveText.bodyMedium(
                skill.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colors[index % colors.length],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Légende du graphique
  Widget _buildLegend(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info, {
    double? fontSize,
  }) {
    final skills = expertise.topSkills.take(5).toList();
    final double size =
        fontSize ?? _getFontSize(info, small: 10, medium: 12, large: 14);

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: skills.asMap().entries.map((entry) {
          final index = entry.key;
          final skill = entry.value;

          return ResponsiveBox(
            paddingSize: ResponsiveSpacing.s,
            padding: EdgeInsets.symmetric(
              vertical: _getSpacing(info, small: 2, medium: 3, large: 4),
            ),
            child: Row(
              children: [
                ResponsiveBox(
                  width: _getSpacing(info, small: 8, medium: 10, large: 12),
                  height: _getSpacing(info, small: 8, medium: 10, large: 12),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                ResponsiveBox(
                    width: _getSpacing(info, small: 4, medium: 6, large: 8)),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText.bodySmall(
                        skill.name,
                        style: TextStyle(
                          fontSize: size,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ResponsiveText.bodySmall(
                        '${skill.levelPercent}% • ${skill.projectCount} projets',
                        style: TextStyle(
                          fontSize: size,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Stats en bas de la carte
  Widget _buildStats(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.work_outline,
          label: '${expertise.totalProjects} projets',
          color: theme.colorScheme.primary,
          info: info,
        ),
        Container(
          width: 1,
          height: 20,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          icon: Icons.calendar_today,
          label: '${expertise.totalYearsExperience} ans',
          color: theme.colorScheme.secondary,
          info: info,
        ),
        Container(
          width: 1,
          height: 20,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        _buildStatItem(
          icon: Icons.star,
          label: '${(expertise.averageLevel * 100).toInt()}%',
          color: Colors.orange,
          info: info,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required Color color,
    required ResponsiveInfo info,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: _getFontSize(info, small: 14, medium: 16, large: 18),
          color: color,
        ),
        ResponsiveBox(width: _getSpacing(info, small: 4, medium: 6, large: 8)),
        ResponsiveText.bodySmall(
          label,
          style: TextStyle(
            fontSize: _getFontSize(info, small: 10, medium: 11, large: 12),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // WIDGETS DE BASE (inchangés)
  // ============================================================================

  Widget _buildBackgroundImage(ThemeData theme) {
    if (!service.hasValidImage) {
      return _buildFallbackGradient(theme);
    }

    return SmartImage(
      path: service.cleanedImageUrl!,
      fit: BoxFit.cover,
      responsiveSize: ResponsiveImageSize.medium,
      fallbackIcon: service.icon,
      fallbackColor: theme.colorScheme.primary,
    );
  }

  Widget _buildOverlay() {
    return ResponsiveBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildFallbackGradient(ThemeData theme) {
    return ResponsiveBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.4),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          service.icon,
          size: 120,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  Widget _buildIconBadge(ThemeData theme, ResponsiveInfo info) {
    final size = _getIconSize(info);

    return ResponsiveBox(
      padding: EdgeInsets.all(size * 0.4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(service.icon, size: size, color: Colors.white),
    );
  }

  Widget _buildExpertiseBadge(ServiceExpertise expertise, ThemeData theme) {
    final level = (expertise.averageLevel * 100).toInt();

    return ResponsiveBox(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColorForLevel(expertise.averageLevel),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          ResponsiveText.headlineSmall(
            '$level% expertise',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLevel(double level) {
    if (level >= 0.9) return Colors.green.shade600;
    if (level >= 0.7) return Colors.blue.shade600;
    if (level >= 0.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  void _showExpertiseDialog(BuildContext context, WidgetRef ref) {
    final expertise = ref.read(serviceExpertiseProvider(service.id));

    if (expertise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données d\'expertise non disponibles'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ResponsiveBox(
          paddingSize: ResponsiveSpacing.l,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ResponsiveText.headlineSmall(
                      'Expertise - ${service.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const ResponsiveBox(height: 24),
              Flexible(
                fit: FlexFit.tight,
                child: SingleChildScrollView(
                  child: ServiceExpertiseCard(expertise: expertise),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  double _getBorderRadius(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  double _getPadding(ResponsiveInfo info) => info.isWatch
      ? 12
      : info.isMobile
          ? 16
          : info.isTablet
              ? 20
              : 24;

  double _getSpacing(
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

  double _getFontSize(
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

  double _getIconSize(ResponsiveInfo info) => info.isWatch
      ? 20
      : info.isMobile
          ? 24
          : info.isTablet
              ? 28
              : 32;
}
