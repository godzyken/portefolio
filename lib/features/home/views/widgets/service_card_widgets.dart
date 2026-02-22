import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/affichage/colors_spec.dart';
import 'service_card_helpers.dart';

class ServiceCardWidgets {
  /// Badge d'icône avec gradient
  static Widget buildIconBadge(
    IconData icon,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final size = ServiceCardHelpers.getIconSize(info);

    return ResponsiveBox(
      padding: EdgeInsets.all(size * 0.3),
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
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }

  /// Badge d'expertise avec étoile
  static Widget buildExpertiseBadge(
    ServiceExpertise expertise,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final level = (expertise.averageLevel * 100).toInt();

    return ResponsiveBox(
      padding: EdgeInsets.symmetric(
        horizontal: ServiceCardHelpers.getSpacing(
          info,
          small: 4,
          medium: 6,
          large: 8,
        ),
        vertical: ServiceCardHelpers.getSpacing(
          info,
          small: 4,
          medium: 6,
          large: 8,
        ),
      ),
      decoration: BoxDecoration(
        color: ColorHelpers.getColorForLevel(expertise.averageLevel),
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
          Icon(
            Icons.star,
            size: ServiceCardHelpers.getFontSize(
              info,
              small: 10,
              medium: 12,
              large: 14,
            ),
            color: Colors.white,
          ),
          SizedBox(
            width: ServiceCardHelpers.getSpacing(
              info,
              small: 3,
              medium: 4,
              large: 5,
            ),
          ),
          ResponsiveText.bodySmall(
            '$level% expertise',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ServiceCardHelpers.getFontSize(
                info,
                small: 9,
                medium: 10,
                large: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton d'expertise 3D
  static Widget buildExpertiseDialogButton({
    required GlobalKey buttonKey,
    required OverlayEntry? overlayEntry,
    required VoidCallback onTap,
    required ThemeData theme,
    required ResponsiveInfo info,
  }) {
    final size = ServiceCardHelpers.getIconSize(info) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(size * 0.25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.6),
            border: Border.all(color: Colors.white, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            overlayEntry != null ? Icons.close : Icons.psychology_outlined,
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Stats d'expertise
  static Widget buildStatItem({
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
          size: ServiceCardHelpers.getFontSize(
            info,
            small: 12,
            medium: 14,
            large: 16,
          ),
          color: color,
        ),
        SizedBox(
          width: ServiceCardHelpers.getSpacing(
            info,
            small: 3,
            medium: 4,
            large: 6,
          ),
        ),
        ResponsiveText.displaySmall(
          label,
          style: TextStyle(
            fontSize: ServiceCardHelpers.getFontSize(
              info,
              small: 9,
              medium: 10,
              large: 11,
            ),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
