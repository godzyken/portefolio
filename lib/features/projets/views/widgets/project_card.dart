import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
import 'package:portefolio/features/projets/views/widgets/unified_project_card.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';
import '../../providers/projects_extentions_providers.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectInfo project;
  final double? width;
  final double? height;

  const ProjectCard({
    super.key,
    required this.project,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building ProjectCard wrapper for ${project.title}');

    return UnifiedProjectCard.adaptive(
      project: project,
      width: width,
      height: height,
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => _buildProjectDialog(context, ref, project),
        );
      },
    );
  }
}

bool _hasProgrammingTag(ProjectInfo project) {
  final titleLower = project.title.toLowerCase();
  return TechIconHelper.getProgrammingTags()
      .any((tag) => titleLower.contains(tag));
}

String? extractYoutubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;

  if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v'];
  }

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
  }

  return null;
}

Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ResponsiveText.bodyMedium(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        ResponsiveText.bodyMedium(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Widget _buildWakaTimeStats(WidgetRef ref, ProjectInfo project) {
  final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

  return statsAsync.when(
    data: (stats) {
      if (stats == null) return const SizedBox.shrink();

      final projectStat = stats.projects.firstWhere(
        (p) => p.name.toLowerCase().contains(project.title.toLowerCase()),
        orElse: () => stats.projects.first,
      );

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const ResponsiveText.bodyLarge(
                  'Statistiques WakaTime (7 jours)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatRow('Temps total', projectStat.text),
            _buildStatRow(
                'Pourcentage', '${projectStat.percent.toStringAsFixed(1)}%'),
            _buildStatRow('Format', projectStat.digital),
          ],
        ),
      );
    },
    loading: () => const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    ),
    error: (_, __) => const SizedBox.shrink(),
  );
}

String _mapPointToEmoji(String point) {
  if (point.contains('objectif')) return '🎯';
  if (point.contains('mission')) return '🛠';
  if (point.contains('résultat')) return '📈';
  return '•';
}

AlertDialog _buildProjectDialog(
  BuildContext context,
  WidgetRef ref,
  ProjectInfo project,
) {
  final pdfService = ref.watch(pdfExportProvider);
  final youtubeId = extractYoutubeId(project.lienProjet ?? '');
  final info = ref.watch(responsiveInfoProvider);

  return AlertDialog(
    title: Row(
      children: [
        Expanded(
          child: ResponsiveText.titleLarge(
            project.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        WakaTimeBadgeWidget(
          projectName: project.title,
          variant: WakaTimeBadgeVariant.simple,
          showTrackingIndicator: true,
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // GESTION DE LA VIDÉO / IMAGE
          if (youtubeId != null && youtubeId.isNotEmpty)
            ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    final controller = YoutubePlayerController.fromVideoId(
                      videoId: youtubeId,
                      autoPlay: false,
                      params: const YoutubePlayerParams(
                        showControls: true,
                        showFullscreenButton: true,
                        mute: false,
                        playsInline: true,
                      ),
                    );

                    return YoutubePlayerControllerProvider(
                      controller: controller,
                      child: YoutubePlayer(
                        controller: controller,
                        aspectRatio: 16 / 9,
                        enableFullScreenOnVerticalDrag: true,
                        key: ValueKey(
                            'youtube_${youtubeId}_${DateTime.now().millisecondsSinceEpoch}'),
                      ),
                    );
                  },
                ),
              ),
            )
          else if (project.cleanedImages != null &&
              project.cleanedImages!.isNotEmpty)
            ResponsiveBox(
              paddingSize: ResponsiveSpacing.m,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: info.size.width * 0.8,
                    maxHeight: info.size.height * 0.4,
                  ),
                  child: SmartImage(
                    path: project.cleanedImages!.first,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else
            const ResponsiveBox(
              paddingSize: ResponsiveSpacing.xs,
            ),

          const ResponsiveBox(
            paddingSize: ResponsiveSpacing.m,
          ),
          WakaTimeBadgeWidget(
            projectName: project.title,
            variant: WakaTimeBadgeVariant.detailed,
            showLoadingFallback: false,
          ).watchTrackingStatus(ref).when(
                data: (isTracked) {
                  if (!isTracked || !_hasProgrammingTag(project)) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _buildWakaTimeStats(ref, project),
                      const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          if (_hasProgrammingTag(project))
            CodeHighlightList(items: project.points, tag: '->')
          else
            Wrap(
              spacing: 6,
              children: project.points.take(3).map((p) {
                return ResponsiveBox(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ResponsiveText.bodyMedium(
                    _mapPointToEmoji(p),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => context.pop(),
        child: const ResponsiveText.bodyMedium('Fermer'),
      ),
      TextButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: const ResponsiveText.bodyMedium('Imprimer ce projet'),
        onPressed: () => pdfService.export([project]),
      ),
    ],
  );
}
