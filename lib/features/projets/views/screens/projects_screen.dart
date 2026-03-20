import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/provider/provider_extentions.dart';
import '../../../generator/views/widgets/immersive_detail_screen.dart';
import '../../data/project_data.dart';
import '../../providers/projects_extentions_providers.dart';
import '../widgets/project_widgets_extentions.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(enrichedProjectsProvider);
    final selected = ref.watch(selectedProjectsProvider);
    final info = ref.watch(responsiveInfoProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: ResponsiveText.bodyMedium('Aucun projet disponible'),
          );
        }

        // Desktop large → vue bulles interactives
        if (info.size.width >= 1024 && info.isLandscape) {
          return Stack(
            children: [
              Positioned.fill(
                child: SmartImage(
                  key: const ValueKey('bg-line'),
                  path: 'assets/images/backgrounds/line.svg',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  height: double.infinity,
                  responsiveSize: ResponsiveImageSize.xlarge,
                  fallbackIcon: Icons.grid_view,
                  fallbackColor: Colors.white,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: ProjectGridView(
                    projects: projects,
                    selected: selected,
                  ),
                ),
              ),
            ],
          );
        }

        // Mobile / tablette → grille de cartes
        return _ProjectCardGrid(projects: projects, selected: selected);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(loggerProvider('ProjectsScreen')).log(
                'Erreur chargement projets',
                level: LogLevel.error,
                error: e,
                stackTrace: st,
              );
        });
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              ResponsiveText.bodyMedium('Erreur : $e'),
              const SizedBox(height: 16),
              ResponsiveButton.icon(
                onPressed: () => ref.invalidate(enrichedProjectsProvider),
                icon: const Icon(Icons.refresh),
                label: 'Réessayer',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vue grille de cartes (mobile / tablette)
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCardGrid extends ConsumerWidget {
  final List<ProjectInfo> projects;
  final List<ProjectInfo> selected;

  const _ProjectCardGrid({
    required this.projects,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    final cols = info.isMobile
        ? 1
        : info.isSmallTablet
            ? 2
            : info.isTablet
                ? 2
                : 3;

    return Padding(
      padding: EdgeInsets.all(info.isMobile ? 12 : 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: info.isMobile ? 1.6 : 1.4,
        ),
        itemCount: projects.length,
        itemBuilder: (context, index) => _ProjectCard(
          project: projects[index],
          isSelected: selected.any((p) => p.id == projects[index].id),
          onTap: () => _openDetail(context, projects[index]),
          onLongPress: () => ref
              .read(selectedProjectsProvider.notifier)
              .toggle(projects[index]),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, ProjectInfo project) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: ImmersiveDetailScreen(project: project),
        ),
        transitionDuration: const Duration(milliseconds: 350),
        fullscreenDialog: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte projet compacte
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final ProjectInfo project;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProjectCard({
    required this.project,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  void _setHovered(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _hovered = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.project.cleanedImages ?? [];
    final hasImage = images.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : Colors.white.withValues(alpha: _hovered ? 0.25 : 0.1),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: _hovered ? 0.4 : 0.25),
                blurRadius: _hovered ? 20 : 10,
                spreadRadius: widget.isSelected ? 2 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Image de fond ──────────────────────────────────────
                if (hasImage)
                  SmartImage(
                    path: images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    enableShimmer: true,
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                          theme.colorScheme.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),

                // ── Overlay gradient ───────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),

                // ── Infos bas ──────────────────────────────────────────
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.project.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.project.tags != null &&
                          widget.project.tags!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.project.tags!
                              .take(3)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Badge sélectionné ──────────────────────────────────
                if (widget.isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // ── Badge WakaTime ─────────────────────────────────────
                if (widget.project.timeSpent != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(widget.project.timeSpent!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h${m > 0 ? ' ${m}m' : ''}';
    return '${m}m';
  }
}
