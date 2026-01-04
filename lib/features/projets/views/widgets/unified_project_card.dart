import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:portefolio/features/projets/data/project_data.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/provider/providers.dart';

enum ProjectCardStyle {
  /// Style adaptatif avec layout responsive
  adaptive,

  /// Style minimal avec animations
  minimal,

  /// Style avec effet hover prononcé
  hover,

  /// Style compact pour listes
  compact,
}

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

class UnifiedProjectCard extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final ProjectCardConfig config;

  const UnifiedProjectCard({
    super.key,
    required this.project,
    this.config = const ProjectCardConfig(),
  });

  factory UnifiedProjectCard.adaptive({
    required ProjectInfo project,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return UnifiedProjectCard(
      project: project,
      config: ProjectCardConfig(
        style: ProjectCardStyle.adaptive,
        onTap: onTap,
      ),
    );
  }

  factory UnifiedProjectCard.minimal({
    required ProjectInfo project,
    double? width,
    double? height,
  }) {
    return UnifiedProjectCard(
      project: project,
      config: ProjectCardConfig(
        style: ProjectCardStyle.minimal,
        width: width,
        height: height,
      ),
    );
  }

  factory UnifiedProjectCard.hover({
    required ProjectInfo project,
    EdgeInsets? margin,
  }) {
    return UnifiedProjectCard(
      project: project,
      config: ProjectCardConfig(
        style: ProjectCardStyle.hover,
        margin: margin,
      ),
    );
  }

  factory UnifiedProjectCard.compact({
    required ProjectInfo project,
    VoidCallback? onTap,
  }) {
    return UnifiedProjectCard(
      project: project,
      config: ProjectCardConfig(
        style: ProjectCardStyle.compact,
        showTechStack: false,
        onTap: onTap,
      ),
    );
  }

  @override
  ConsumerState<UnifiedProjectCard> createState() => _UnifiedProjectCardState();
}

class _UnifiedProjectCardState extends ConsumerState<UnifiedProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    return _buildCardWrapper(
      child: _buildCardContent(info, theme),
      info: info,
      theme: theme,
    );
  }

  Widget _buildCardWrapper({
    required Widget child,
    required ResponsiveInfo info,
    required ThemeData theme,
  }) {
    final config = widget.config;

    // Base container avec gestion du hover
    Widget card = MouseRegion(
      onEnter:
          config.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit:
          config.enableHover ? (_) => setState(() => _isHovered = false) : null,
      cursor: config.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: child,
    );

    // Appliquer le style selon la configuration
    switch (config.style) {
      case ProjectCardStyle.hover:
        card = _applyHoverStyle(card, theme, info);
        break;

      case ProjectCardStyle.minimal:
        card = _applyMinimalStyle(card, theme, info);
        break;

      case ProjectCardStyle.compact:
        card = _applyCompactStyle(card, theme, info);
        break;

      case ProjectCardStyle.adaptive:
        card = _applyAdaptiveStyle(card, theme, info);
    }

    // Appliquer les dimensions si spécifiées
    if (config.width != null || config.height != null) {
      card = SizedBox(
        width: config.width,
        height: config.height,
        child: card,
      );
    }

    // Appliquer la marge
    if (config.margin != null) {
      card = Padding(
        padding: config.margin!,
        child: card,
      );
    }

    return card;
  }

  Widget _applyHoverStyle(Widget child, ThemeData theme, ResponsiveInfo info) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: config.margin ?? const EdgeInsets.all(16),
      transform: _isHovered
          ? (Matrix4.identity()
            ..translateByVector3(Vector3(0.0, -6.0, 0.0))
            ..scaleByVector3(Vector3.all(1.02)))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(
              alpha: _isHovered ? 0.30 : 0.10,
            ),
            blurRadius: _isHovered ? 18 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _applyMinimalStyle(
      Widget child, ThemeData theme, ResponsiveInfo info) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(8),
      transform: Matrix4.identity()
        ..scaledByVector3(Vector3.all(_isHovered ? 1.05 : 1.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isHovered
                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: _isHovered ? 20 : 12,
            offset: Offset(0, _isHovered ? 10 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }

  Widget _applyCompactStyle(
      Widget child, ThemeData theme, ResponsiveInfo info) {
    return Card(
      margin: config.margin ?? const EdgeInsets.all(8),
      elevation: _isHovered ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _applyAdaptiveStyle(
      Widget child, ThemeData theme, ResponsiveInfo info) {
    return Card(
      margin: config.margin ?? const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: _isHovered ? 8 : 4,
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }

  Widget _buildCardContent(ResponsiveInfo info, ThemeData theme) {
    final config = widget.config;

    switch (config.style) {
      case ProjectCardStyle.compact:
        return _buildCompactContent(info, theme);

      case ProjectCardStyle.minimal:
        return _buildMinimalContent(info, theme);

      case ProjectCardStyle.hover:
      case ProjectCardStyle.adaptive:
        return _buildAdaptiveContent(info, theme);
    }
  }

  Widget _buildCompactContent(ResponsiveInfo info, ThemeData theme) {
    return InkWell(
      onTap: config.onTap ?? () => _showProjectDialog(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image miniature
            if (_hasImages)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SmartImage(
                  path: _firstImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  responsiveSize: ResponsiveImageSize.small,
                ),
              ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.bodyLarge(
                    widget.project.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.project.points.isNotEmpty)
                    ResponsiveText.bodySmall(
                      widget.project.points.first,
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

            // Flèche
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

  Widget _buildMinimalContent(ResponsiveInfo info, ThemeData theme) {
    return InkWell(
      onTap: config.onTap ?? () => _showImmersiveDetails(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond avec zoom au hover
          AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: _buildBackground(theme, info),
          ),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: _isHovered ? 0.8 : 0.7),
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
                fontSize: _isHovered
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
                widget.project.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Badge WakaTime si activé
          if (config.showWakaTime && _hasProgrammingTag)
            Positioned(
              top: 16,
              left: 16,
              child: WakaTimeBadgeWidget(
                projectName: widget.project.title,
              ),
            ),

          // Icône plein écran
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isHovered
                    ? theme.colorScheme.primary.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: _isHovered ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveContent(ResponsiveInfo info, ThemeData theme) {
    final useRowLayout = info.isDesktop || info.isTablet || info.isLandscape;

    return InkWell(
      onTap: config.onTap ?? () => _showProjectDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useRowLayout)
            Expanded(
              child: Row(
                children: [
                  // Image/Vidéo à gauche
                  if (_hasImages || config.enableVideoPlayback)
                    Expanded(
                      flex: 3,
                      child: _buildMediaSection(info, theme),
                    ),
                  if (_hasImages || config.enableVideoPlayback)
                    const VerticalDivider(width: 1),

                  // Contenu à droite
                  Expanded(
                    flex: 2,
                    child: _buildTextSection(info, theme),
                  ),
                ],
              ),
            )
          else
            // Layout vertical pour mobile
            Expanded(
              child: Column(
                children: [
                  // Image en haut
                  if (_hasImages || config.enableVideoPlayback)
                    Flexible(
                      flex: 50,
                      child: _buildMediaSection(info, theme),
                    ),
                  if (_hasImages || config.enableVideoPlayback)
                    const Divider(height: 1),

                  // Contenu en bas
                  Flexible(
                    flex: 50,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildTextSection(info, theme),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(ResponsiveInfo info, ThemeData theme) {
    final playingId = ref.watch(playingVideoProvider);
    final isActiveVideo = playingId == widget.project.title &&
        config.enableVideoPlayback &&
        widget.project.youtubeVideoId != null;

    // Tags spéciaux
    final hasSIG = widget.project.points.contains('SIG');

    Widget content;

    if (hasSIG) {
      content = const SigDiscoveryMap();
    } else if (isActiveVideo) {
      content = YoutubeVideoPlayerIframe(
        youtubeVideoId: widget.project.youtubeVideoId!,
        cardId: widget.project.id,
      );
    } else if (_hasImages) {
      content = SmartImage(
        path: _firstImage,
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
      key: ValueKey(isActiveVideo
          ? 'video_${widget.project.id}'
          : 'image_${widget.project.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,

          // Badge si SIG
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

  Widget _buildTextSection(ResponsiveInfo info, ThemeData theme) {
    final bulletsToShow = widget.project.points.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre
          ResponsiveText.titleMedium(
            widget.project.title,
            style: TextStyle(
              fontSize: info.isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Badge WakaTime
          if (config.showWakaTime && _hasProgrammingTag)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WakaTimeBadgeWidget(
                projectName: widget.project.title,
              ),
            ),

          // Points clés
          if (_hasProgrammingTag)
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
                          style: TextStyle(
                            fontSize: info.isMobile ? 13 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

          // Indicateur "voir plus"
          if (widget.project.points.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${widget.project.points.length - 3} autres…',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),

          const Spacer(),

          // Tech stack si activé
          if (config.showTechStack && widget.project.platform != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.project.platform!
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

  Widget _buildBackground(ThemeData theme, ResponsiveInfo info) {
    if (_hasImages) {
      return SmartImage(
        path: _firstImage,
        fit: BoxFit.cover,
        responsiveSize: ResponsiveImageSize.large,
        fallbackIcon: Icons.workspace_premium,
        fallbackColor: theme.colorScheme.primary,
      );
    }

    // Fallback gradient
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

  void _showProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ProjectDialog(project: widget.project),
    );
  }

  void _showImmersiveDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImmersiveDetailScreen(project: widget.project),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // Helpers
  ProjectCardConfig get config => widget.config;

  bool get _hasImages => widget.project.cleanedImages?.isNotEmpty ?? false;

  String get _firstImage => widget.project.cleanedImages?.first ?? '';

  bool get _hasProgrammingTag {
    final titleLower = widget.project.title.toLowerCase();
    return TechIconHelper.getProgrammingTags()
        .any((tag) => titleLower.contains(tag));
  }
}

class _ProjectDialog extends StatelessWidget {
  final ProjectInfo project;

  const _ProjectDialog({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: ResponsiveText.titleLarge(
        project.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.cleanedImages?.isNotEmpty ?? false)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SmartImage(
                  path: project.cleanedImages!.first,
                  fit: BoxFit.contain,
                  responsiveSize: ResponsiveImageSize.large,
                ),
              ),
            const SizedBox(height: 16),
            ...project.points.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResponsiveText.bodyMedium(point),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const ResponsiveText.bodyMedium('Fermer'),
        ),
      ],
    );
  }
}
