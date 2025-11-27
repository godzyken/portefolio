import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../../core/affichage/screen_size_detector.dart';
import '../../../../../core/provider/expertise_provider.dart';
import '../../../../../core/ui/widgets/ui_widgets_extentions.dart';
import 'extentions_widgets.dart';

class ServiceCardTopSection extends ConsumerWidget {
  final Service service;
  final GlobalKey buttonKey;
  final OverlayEntry? overlayEntry;
  final Function(ServiceExpertise, ResponsiveInfo) onToggleSkillBubbles;

  const ServiceCardTopSection({
    super.key,
    required this.service,
    required this.buttonKey,
    required this.overlayEntry,
    required this.onToggleSkillBubbles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final expertise = ref.watch(serviceExpertiseProvider(service.id));

    return Stack(
      fit: StackFit.expand,
      children: [
        ServiceCardBackground(service: service),
        ResponsiveBox(
          padding: EdgeInsets.all(ServiceCardHelpers.getPadding(info)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge d'expertise en haut
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (expertise != null)
                    ServiceCardWidgets.buildExpertiseBadge(
                      expertise,
                      theme,
                      info,
                    ),
                  if (expertise != null)
                    SizedBox(
                      width: ServiceCardHelpers.getSpacing(
                        info,
                        small: 8,
                        medium: 10,
                        large: 12,
                      ),
                    ),
                  ServiceCardWidgets.buildExpertiseDialogButton(
                    buttonKey: buttonKey,
                    overlayEntry: overlayEntry,
                    onTap: () {
                      if (expertise != null) {
                        onToggleSkillBubbles(expertise, info);
                      }
                    },
                    theme: theme,
                    info: info,
                  ),
                ],
              ),

              // Titre et icône en bas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ServiceCardWidgets.buildIconBadge(
                        service.icon,
                        theme,
                        info,
                      ),
                      ResponsiveBox(
                        width: ServiceCardHelpers.getSpacing(
                          info,
                          small: 8,
                          medium: 10,
                          large: 12,
                        ),
                      ),
                      Expanded(
                        child: ResponsiveText.titleMedium(
                          service.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ServiceCardHelpers.getFontSize(
                              info,
                              small: 14,
                              medium: 16,
                              large: 18,
                            ),
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
                    height: ServiceCardHelpers.getSpacing(
                      info,
                      small: 4,
                      medium: 6,
                      large: 8,
                    ),
                  ),
                  ResponsiveText.bodySmall(
                    service.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: ServiceCardHelpers.getFontSize(
                        info,
                        small: 11,
                        medium: 12,
                        large: 13,
                      ),
                      height: 1.3,
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
}
