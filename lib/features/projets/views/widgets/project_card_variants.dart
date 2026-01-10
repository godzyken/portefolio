import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../core/provider/providers.dart';
import '../../../generator/views/generator_widgets_extentions.dart';

/// Configuration pour ProjectCard
class ProjectCardConfig {
  final ProjectCardStyle style;
  final bool enableHover;
  final bool showWakaTime;
  final bool showTechStack;
  final bool enableVideoPlayback;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const ProjectCardConfig({
    this.style = ProjectCardStyle.adaptive,
    this.enableHover = true,
    this.showWakaTime = true,
    this.showTechStack = true,
    this.enableVideoPlayback = true,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  ProjectCardConfig copyWith({
    ProjectCardStyle? style,
    bool? enableHover,
    bool? showWakaTime,
    bool? showTechStack,
    bool? enableVideoPlayback,
    EdgeInsets? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return ProjectCardConfig(
      style: style ?? this.style,
      enableHover: enableHover ?? this.enableHover,
      showWakaTime: showWakaTime ?? this.showWakaTime,
      showTechStack: showTechStack ?? this.showTechStack,
      enableVideoPlayback: enableVideoPlayback ?? this.enableVideoPlayback,
      margin: margin ?? this.margin,
      width: width ?? this.width,
      height: height ?? this.height,
      onTap: onTap ?? this.onTap,
    );
  }
}

enum ProjectCardStyle {
  adaptive,
  minimal,
  hover,
  compact,
}

/// Contenu compact pour ProjectCard
class ProjectCardCompactContent extends StatelessWidget {
  final ProjectInfo project;
  final ThemeData theme;
  final VoidCallback onTap;

  const ProjectCardCompactContent({
    super.key,
    required this.project,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = project.cleanedImages?.isNotEmpty ?? false;
    final firstImage = hasImages ? project.cleanedImages!.first : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (hasImages)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SmartImage(
                  path: firstImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  responsiveSize: ResponsiveImageSize.small,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.bodyLarge(
                    project.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.points.isNotEmpty)
                    ResponsiveText.bodySmall(
                      project.points.first,
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenu minimal pour ProjectCard
class ProjectCardMinimalContent extends StatelessWidget {
  final ProjectInfo project;
  final ThemeData theme;
  final ResponsiveInfo info;
  final bool isHovered;
  final bool showWakaTime;
  final VoidCallback onTap;

  const ProjectCardMinimalContent({
    super.key,
    required this.project,
    required this.theme,
    required this.info,
    required this.isHovered,
    required this.showWakaTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = project.cleanedImages?.isNotEmpty ?? false;
    final hasProgrammingTag = _checkProgrammingTag();

    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond avec zoom au hover
          AnimatedScale(
            scale: isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: _buildBackground(hasImages, theme),
          ),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: isHovered ? 0.8 : 0.7),
                ],
              ),
            ),
          ),

          // Titre en bas
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isHovered
                    ? (info.isMobile ? 18 : 22)
                    : (info.isMobile ? 16 : 20),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                project.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Badge WakaTime
          if (showWakaTime && hasProgrammingTag)
            Positioned(
              top: 16,
              left: 16,
              child: WakaTimeBadgeWidget(projectName: project.title),
            ),

          // Icône plein écran
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovered
                    ? theme.colorScheme.primary.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: isHovered ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool hasImages, ThemeData theme) {
    if (hasImages) {
      return SmartImage(
        path: project.cleanedImages!.first,
        fit: BoxFit.cover,
        responsiveSize: ResponsiveImageSize.large,
        fallbackIcon: Icons.workspace_premium,
        fallbackColor: theme.colorScheme.primary,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  bool _checkProgrammingTag() {
    final titleLower = project.title.toLowerCase();
    return TechIconHelper.getProgrammingTags()
        .any((tag) => titleLower.contains(tag));
  }
}

/// Section média pour ProjectCard
class ProjectCardMediaSection extends ConsumerWidget {
  final ProjectInfo project;
  final ThemeData theme;
  final ResponsiveInfo info;
  final bool enableVideoPlayback;

  const ProjectCardMediaSection({
    super.key,
    required this.project,
    required this.theme,
    required this.info,
    required this.enableVideoPlayback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingId = ref.watch(playingVideoProvider);
    final isActiveVideo = playingId == project.title &&
        enableVideoPlayback &&
        project.youtubeVideoId != null;

    final hasSIG = project.points.contains('SIG');
    final hasImages = project.cleanedImages?.isNotEmpty ?? false;

    Widget content;

    if (hasSIG) {
      content = const SigDiscoveryMap();
    } else if (isActiveVideo) {
      content = YoutubeVideoPlayerIframe(
        youtubeVideoId: project.youtubeVideoId!,
        cardId: project.id,
      );
    } else if (hasImages) {
      content = SmartImage(
        path: project.cleanedImages!.first,
        fit: BoxFit.cover,
        responsiveSize: ResponsiveImageSize.medium,
        fallbackIcon: Icons.business,
      );
    } else {
      content = Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 60,
          ),
        ),
      );
    }

    return FadeSlideAnimation(
      key: ValueKey(
          isActiveVideo ? 'video_${project.id}' : 'image_${project.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (hasSIG)
            const Positioned(
              top: 8,
              left: 8,
              child: Chip(
                label: Text(
                  'SIG',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Color(0xFF00796B),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

/// Section texte pour ProjectCard
class ProjectCardTextSection extends StatelessWidget {
  final ProjectInfo project;
  final ThemeData theme;
  final ResponsiveInfo info;
  final bool showWakaTime;
  final bool showTechStack;

  const ProjectCardTextSection({
    super.key,
    required this.project,
    required this.theme,
    required this.info,
    required this.showWakaTime,
    required this.showTechStack,
  });

  @override
  Widget build(BuildContext context) {
    final bulletsToShow = project.points.take(3).toList();
    final hasProgrammingTag = _checkProgrammingTag();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre
          ResponsiveText.titleMedium(
            project.title,
            style: TextStyle(
              fontSize: info.isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Badge WakaTime
          if (showWakaTime && hasProgrammingTag)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WakaTimeBadgeWidget(projectName: project.title),
            ),

          // Points clés
          if (hasProgrammingTag)
            CodeHighlightList(items: bulletsToShow, tag: '//')
          else
            ...bulletsToShow.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ResponsiveText.bodySmall(
                          point,
                          style: TextStyle(fontSize: info.isMobile ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                )),

          if (project.points.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${project.points.length - 3} autres…',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),

          const Spacer(),

          // Tech stack
          if (showTechStack && project.platform != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: project.platform!
                    .map((platform) => Chip(
                          label: ResponsiveText.bodySmall(
                            platform,
                            style: theme.textTheme.bodySmall,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  bool _checkProgrammingTag() {
    final titleLower = project.title.toLowerCase();
    return TechIconHelper.getProgrammingTags()
        .any((tag) => titleLower.contains(tag));
  }
}
