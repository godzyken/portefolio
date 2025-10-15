import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../parametres/views/widgets/smart_image.dart';

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
      onTap: onTap,
      child: HoverCard(
        id: service.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_getBorderRadius(info)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _buildCardContent(context, theme, info, constraints);
            },
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
    BoxConstraints constraints,
  ) {
    // Layout vertical pour mobile/portrait
    if (info.isMobile || info.isWatch || info.isPortrait) {
      return _buildVerticalLayout(theme, info, constraints);
    }

    // Layout horizontal pour desktop/landscape
    return _buildHorizontalLayout(theme, info, constraints);
  }

  Widget _buildVerticalLayout(
    ThemeData theme,
    ResponsiveInfo info,
    BoxConstraints constraints,
  ) {
    final imageHeight = constraints.maxHeight * 0.5;
    final contentHeight = constraints.maxHeight * 0.5;

    return Column(
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(theme),
              _buildOverlay(),
            ],
          ),
        ),
        Container(
          height: contentHeight,
          padding: EdgeInsets.all(_getPadding(info)),
          child: _buildContent(theme, info, compact: true),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    ThemeData theme,
    ResponsiveInfo info,
    BoxConstraints constraints,
  ) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBackgroundImage(theme)),
        Positioned.fill(child: _buildOverlay()),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(_getPadding(info)),
            child: _buildContent(theme, info, compact: false),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ResponsiveInfo info,
      {required bool compact}) {
    return Column(
      mainAxisAlignment:
          compact ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconBadge(theme, info),
        SizedBox(height: _getSpacing(info, small: 12, medium: 16, large: 20)),
        Text(
          service.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: _getFontSize(info, small: 18, medium: 22, large: 26),
          ),
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: _getSpacing(info, small: 8, medium: 10, large: 12)),
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              service.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
                fontSize: _getFontSize(info, small: 12, medium: 14, large: 16),
              ),
              maxLines: compact ? 3 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
            ),
          ),
        ),
        SizedBox(height: _getSpacing(info, small: 12, medium: 14, large: 16)),
        _buildFeatures(info, compact: compact),
      ],
    );
  }

  Widget _buildBackgroundImage(ThemeData theme) {
    if (!service.hasValidImage) {
      return _buildFallbackGradient(theme);
    }

    return SmartImage(
      path: service.cleanedImageUrl!,
      fit: BoxFit.cover,
      fallbackIcon: service.icon,
      fallbackColor: theme.colorScheme.primary,
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.black.withValues(alpha: 0.45),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildFallbackGradient(ThemeData theme) {
    return Container(
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

    return Container(
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

  Widget _buildFeatures(ResponsiveInfo info, {required bool compact}) {
    final maxFeatures = compact ? 3 : service.features.length;
    final displayFeatures = service.features.take(maxFeatures).toList();

    return Wrap(
      spacing: _getSpacing(info, small: 6, medium: 8, large: 10),
      runSpacing: _getSpacing(info, small: 6, medium: 8, large: 10),
      children: displayFeatures.map((feature) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getPadding(info) * 0.6,
            vertical: _getPadding(info) * 0.3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            feature,
            style: TextStyle(
              color: Colors.white,
              fontSize: _getFontSize(info, small: 10, medium: 11, large: 12),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helpers
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

/// Widget de debug pour tester l'affichage d'une image
/*
class ServiceImageDebug extends StatelessWidget {
  final Service service;

  const ServiceImageDebug({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug: ${service.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${service.title}'),
                    const SizedBox(height: 8),
                    Text('Original URL: ${service.imageUrl ?? "null"}'),
                    const SizedBox(height: 8),
                    Text('Cleaned URL: ${service.cleanedImageUrl ?? "null"}'),
                    const SizedBox(height: 8),
                    Text('Has Valid Image: ${service.hasValidImage}'),
                    const SizedBox(height: 8),
                    Text('Is Network: ${service.isNetworkImage}'),
                    const SizedBox(height: 8),
                    Text('Is Asset: ${service.isAssetImage}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test d'affichage
            const Text(
              'Test d\'affichage:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (service.hasValidImage)
              SizedBox(
                height: 300,
                child: SmartImage(
                  path: service.cleanedImageUrl!,
                  fit: BoxFit.contain,
                  fallbackIcon: service.icon,
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey.shade300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(service.icon, size: 64),
                      const SizedBox(height: 8),
                      const Text('Pas d\'image disponible'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/
