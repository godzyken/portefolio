import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

class ServiceCardBackground extends StatelessWidget {
  final Service service;

  const ServiceCardBackground({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundImage(theme),
        _buildOverlay(),
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
      responsiveSize: ResponsiveImageSize.medium,
      fallbackIcon: service.icon,
      fallbackColor: theme.colorScheme.primary,
      autoPreload: true,
      enableShimmer: false,
    );
  }

  Widget _buildOverlay() {
    return Container(
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
    return RepaintBoundary(
      child: ResponsiveBox(
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
      ),
    );
  }
}
