import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/tracking_provider.dart';
import 'package:portefolio/core/service/tracking_service.dart';
import 'package:portefolio/core/ui/sections/section_system.dart';
import 'package:portefolio/features/projets/data/project_data.dart';
import 'package:portefolio/landing_pages/pages/landing_amoa_page.dart';
import 'package:portefolio/landing_pages/pages/landing_flutter_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'live_preview_frame_stub.dart'
    if (dart.library.js_util) 'live_preview_frame_web.dart' as frame_impl;
import 'project_video_player.dart';

class LivePreviewSection extends ConsumerWidget {
  final ProjectInfo project;
  final ResponsiveInfo info;

  const LivePreviewSection({
    super.key,
    required this.project,
    required this.info,
  });

  bool get hasValidUrl =>
      project.lienProjet != null && project.lienProjet!.trim().isNotEmpty;

  String get url => project.lienProjet ?? "";

  bool get _isFlutter {
    final titleLower = project.title.toLowerCase();
    final tags = project.tags?.map((t) => t.toLowerCase()).toList() ?? [];
    final pointsText = project.points.join(' ').toLowerCase();
    return titleLower.contains('flutter') ||
        tags.contains('flutter') ||
        pointsText.contains('flutter');
  }

  Future<void> _openExternally(WidgetRef ref) async {
    if (!hasValidUrl) return;
    final uri = Uri.parse(url);

    ref.read(trackingServiceProvider).trackInteraction(
      projectId: project.analyticsId,
      projectName: project.title,
      action: TrackingAction.linkClick,
      details: {'url': url, 'source': 'portfolio_live_preview'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewHeight = (info.size.height * 0.6).clamp(360.0, 720.0);

    if (!hasValidUrl) {
      return SectionBuilder.simple(
        title:
            _isFlutter ? 'Landing Page Flutter' : 'Landing Page AMOA & Conseil',
        icon: Icons.public,
        accentColor:
            _isFlutter ? const Color(0xFF027DFD) : const Color(0xFF38BDF8),
        child: SizedBox(
          height: previewHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isFlutter
                ? const LandingFlutterContent()
                : const LandingAmoaContent(),
          ),
        ),
      );
    }

    final hasVideo = project.videoAsset != null;
    final useRow = info.size.width > 1200 && hasVideo;

    return SectionBuilder.simple(
      title: 'Aperçu et Présentation',
      icon: Icons.public,
      accentColor: ColorHelpers.chartColors[4],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _openExternally(ref),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Nouvel onglet'),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColorHelpers.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: ColorHelpers.cyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Si le site s'affiche en blanc ou bloque l'intégration (sécurité X-Frame-Options du site hôte), cliquez sur « Nouvel onglet » pour le consulter directement.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (useRow)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: ProjectVideoPlayer(
                    videoPath: project.videoAsset!,
                    label: 'Présentation Vidéo',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: previewHeight,
                    child: _buildPreviewFrame(context, ref),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                if (hasVideo) ...[
                  ProjectVideoPlayer(
                    videoPath: project.videoAsset!,
                    label: 'Présentation Vidéo',
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  height: previewHeight,
                  child: _buildPreviewFrame(context, ref),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewFrame(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb ? _buildIframe(ref) : _buildNativeFallback(context, ref),
    );
  }

  Widget _buildIframe(WidgetRef ref) {
    return frame_impl.buildLivePreviewIframe(url);
  }

  Widget _buildNativeFallback(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Aperçu Web externe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              url,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openExternally(ref),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir dans le navigateur'),
            ),
          ],
        ),
      ),
    );
  }
}
