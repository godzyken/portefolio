import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/generator/services/pdf_export_service.dart';
import 'package:portefolio/features/generator/views/widgets/generator_widgets_extentions.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../data/project_data.dart';
import '../../providers/projects_wakatime_service_provider.dart';

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
    // wrap with LayoutBuilder so the card adapts if no width/height passed
    return LayoutBuilder(builder: (context, constraints) {
      final w = width ?? constraints.maxWidth;
      final h = height ?? constraints.maxHeight;

      // you can adjust aspect ratio or layout depending on w/h here
      return SizedBox(
        width: w,
        height: h,
        child: _buildCardContent(context, ref, Size(w, h)),
      );
    });
  }

  Widget _buildCardContent(BuildContext context, WidgetRef ref, Size size) {
    final pdfService = ref.watch(pdfExportProvider);

    return HoverCard(
      id: project.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: AdaptiveCard(
          title: project.title,
          bulletPoints: project.points,
          imagePath: (project.cleanedImages?.isNotEmpty ?? false)
              ? project.cleanedImages!.first
              : project.cleanedImages!.last,
          onTap: () => showDialog(
            context: context,
            builder: (_) => buildAlertDialog(context, ref, pdfService),
          ),
          imageBuilder: project.cleanedImages!.isNotEmpty
              ? (ctx, size) => _buildImage(size)
              : null,
          videoBuilder: (context, size) {
            if (project.youtubeVideoId == null &&
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
          badgeBuilder: (context, size) => Padding(
            padding: const EdgeInsets.all(8),
            child: WakaTimeDetailedBadge(projectName: project.title),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Size size) {
    final displayW = size.width;
    final displayH =
        size.height * 0.50; // par exemple image prend 50% hauteur du card
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
    final isTracked = ref.watch(isProjectTrackedProvider(project.title));

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: ResponsiveText.titleLarge(
              project.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // 🔹 Badge WakaTime dans le dialogue
          if (isTracked)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: WakaTimeBadge(
                projectName: project.title,
                showTimeSpent: true,
                showTrackingIndicator: true,
              ),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (youtubeId != null && youtubeId.isNotEmpty) // 🎬 YouTube
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
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
                project.cleanedImages!.isNotEmpty) // 🖼 Image
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
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
              const SizedBox.shrink(),

            const SizedBox(height: 6),

            // --- WakaTime badge ---
            if (_hasProgrammingTag())
              WakaTimeDetailedBadge(projectName: project.title),

            const SizedBox(height: 12),
            if (_hasProgrammingTag())
              CodeHighlightList(items: project.points, tag: '->')
            else
              Wrap(
                spacing: 6,
                children: project.points.take(3).map((p) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
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
          onPressed: () {
            context.pop();
          },
          child: const Text('Fermer'),
        ),
        TextButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Imprimer ce projet'),
          onPressed: () => pdfService.export([project]),
        ),
      ],
    );
  }

  /// 🔎 Récupère l'ID de la vidéo YouTube depuis son URL
  String? extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // cas classiques : youtube.com/watch?v=ID
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }

    // cas courts : youtu.be/ID
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    return null;
  }

  String _mapPointToEmoji(String point) {
    if (point.contains('objectif')) return '🎯';
    if (point.contains('mission')) return '🛠';
    if (point.contains('résultat')) return '📈';
    return '•'; // fallback bullet
  }
}
