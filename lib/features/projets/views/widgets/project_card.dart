import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/generator/services/pdf_export_service.dart';
import 'package:portefolio/features/generator/views/widgets/code_high_light_list.dart';
import 'package:portefolio/features/generator/views/widgets/fade_slide_animation.dart';
import 'package:portefolio/features/generator/views/widgets/hover_card.dart';
import 'package:portefolio/features/generator/views/widgets/youtube_video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';
import '../../../generator/views/widgets/adaptive_card.dart';
import '../../data/project_data.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectInfo project;
  const ProjectCard({super.key, required this.project});

  bool _hasProgrammingTag() {
    const programmingTags = ['e-commerce', 'flutter', 'angular', 'digital'];

    final titleLower = project.title.toLowerCase();
    return programmingTags.any((tag) => titleLower.contains(tag));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfExportProvider);

    return HoverCard(
      id: project.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: AdaptiveCard(
          title: project.title,
          bulletPoints: project.points,
          imagePath: (project.image?.isNotEmpty ?? false)
              ? project.image!.first
              : null,
          onTap: () => showDialog(
            context: context,
            builder: (_) => buildAlertDialog(context, ref, pdfService),
          ),
          imageBuilder: project.image!.isNotEmpty
              ? (ctx, size) => _buildImage(size)
              : null,
          videoBuilder: (context, size) {
            if (project.lienProjet == null) return const SizedBox.shrink();
            return FadeSlideAnimation(
              duration: const Duration(milliseconds: 600),
              offset: const Offset(0, 0.1),
              child: YoutubeVideoPlayerIframe(
                videoUrl: project.lienProjet!,
                cardId: project.title,
              ),
            );
          },
        ),
      ),
    );
  }

  AspectRatio _buildImage(Size size) {
    return AspectRatio(
      aspectRatio: size.aspectRatio * 1.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          project.image!.first,
          fit: BoxFit.cover,
          height: size.height,
          width: size.width,
        ),
      ),
    );
  }

  AlertDialog buildAlertDialog(
    BuildContext context,
    WidgetRef ref,
    PdfExportService pdfService,
  ) {
    final youtubeId = extractYoutubeId(project.lienProjet ?? '');
    final info = ref.watch(responsiveInfoProvider);

    return AlertDialog(
      title: Text(
        project.title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                          key: ValueKey(youtubeId),
                        ),
                      );
                    },
                  ),
                ),
              )
            else if (project.image != null &&
                project.image!.isNotEmpty) // 🖼 Image
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: info.size.width * 0.8,
                      maxHeight: info.size.height * 0.4,
                    ),
                    child: Image.asset(
                      project.image!.first,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (_hasProgrammingTag())
              CodeHighlightList(items: project.points, tag: '->')
            else
              Wrap(
                spacing: 6,
                children: project.points.take(3).map((p) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withAlpha((255 * 0.2).toInt()),
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
