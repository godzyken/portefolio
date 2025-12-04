import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/ui_widgets_extentions.dart';
import 'package:portefolio/features/generator/services/pdf_export_service.dart';
import 'package:portefolio/features/generator/views/generator_widgets_extentions.dart';
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

  bool _hasProgrammingTag() {
    const programmingTags = ['e-commerce', 'flutter', 'angular', 'digital'];
    final titleLower = project.title.toLowerCase();
    return programmingTags.any((tag) => titleLower.contains(tag));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = width ?? constraints.maxWidth;
      final h = height ?? constraints.maxHeight;

      return SizedBox(
        width: w,
        height: h,
        child: _buildCardContent(context, ref, Size(w, h)),
      );
    });
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref, Size size) {
    final pdfService = ref.watch(pdfExportProvider);

    developer.log('Building card for ${project.title}');

    return HoverCard(
      id: project.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: AdaptiveCard(
          title: project.title,
          bulletPoints: project.points,
          imagePath: (project.cleanedImages?.isNotEmpty ?? false)
              ? project.cleanedImages?.first
              : project.cleanedImages?.last,
          onTap: () => showDialog(
            context: context,
            builder: (_) => buildAlertDialog(context, ref, pdfService),
          ),
          imageBuilder: project.cleanedImages!.isNotEmpty
              ? (ctx, size) => _buildImage(size)
              : null,
          videoBuilder: (context, size) {
            if (project.youtubeVideoId == null ||
                project.youtubeVideoId!.isEmpty) {
              return _buildImage(size);
            }
            return FadeSlideAnimation(
              duration: const Duration(milliseconds: 600),
              offset: const Offset(0, 0.1),
              child: YoutubeVideoPlayerIframe(
                youtubeVideoId: project.youtubeVideoId!,
                cardId: project.id,
              ),
            );
          },
          // 🎯 Badge WakaTime sur la carte (version sécurisée)
          badgeBuilder: _hasProgrammingTag()
              ? (context, size) => Positioned(
                    top: 12,
                    right: 12,
                    child: SafeWakaTimeDetailedBadge(
                      projectName: project.title,
                    ),
                  )
              : null,
        ),
      ),
    );
  }

  Widget _buildImage(Size size) {
    final displayW = size.width;
    final displayH = size.height * 0.50;

    if ((project.cleanedImages?.length ?? 0) > 1) {
      return PageView(
        children: project.cleanedImages!
            .map((img) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SmartImage(
                    path: img,
                    width: displayW,
                    height: displayH,
                    fit: BoxFit.cover,
                  ),
                ))
            .toList(),
      );
    } else if (project.cleanedImages != null &&
        project.cleanedImages!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SmartImage(
          path: project.cleanedImages!.first,
          width: displayW,
          height: displayH,
          fit: BoxFit.cover,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  AlertDialog buildAlertDialog(
    BuildContext context,
    WidgetRef ref,
    PdfExportService pdfService,
  ) {
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
          // 🔹 Badge WakaTime dans le dialogue (version sécurisée)
          SafeWakaTimeBadge(
            projectName: project.title,
            showTimeSpent: true,
            showTrackingIndicator: true,
            compact: true,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
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

            // --- WakaTime stats détaillées (version sécurisée) ---
            WakaTimeConditionalWidget(
              projectName: project.title,
              builder: (isTracked) {
                if (!isTracked || !_hasProgrammingTag()) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _buildWakaTimeStats(ref),
                    const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                  ],
                );
              },
            ),

            if (_hasProgrammingTag())
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

  Widget _buildWakaTimeStats(WidgetRef ref) {
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
                  Icon(Icons.access_time,
                      color: Colors.blue.shade700, size: 20),
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

  String _mapPointToEmoji(String point) {
    if (point.contains('objectif')) return '🎯';
    if (point.contains('mission')) return '🛠';
    if (point.contains('résultat')) return '📈';
    return '•';
  }
}
