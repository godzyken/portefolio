import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/provider/tracking_provider.dart';
import 'package:portefolio/core/service/tracking_service.dart';
import 'package:portefolio/core/ui/sections/section_system.dart';
import 'package:portefolio/features/projets/data/project_data.dart';
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

  String get url => project.lienProjet ?? "";

  Future<void> _openExternally(WidgetRef ref) async {
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
    // Hauteur explicite (et non un Expanded) : cette section est insérée
    // dans un Container dont le parent (SectionBuilder) se dimensionne à
    // son contenu, donc une hauteur non bornée y arriverait potentiellement

    final previewHeight = (info.size.height * 0.6).clamp(360.0, 720.0);
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb ? _buildIframe(ref) : _buildNativeFallback(context, ref),
    );
  }

  Widget _buildIframe(WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          frame_impl.buildLivePreviewIframe(url),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openExternally(ref),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          size: 14, color: Colors.cyanAccent),
                      SizedBox(width: 6),
                      Text(
                        'Ouvrir en direct',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeFallback(BuildContext context, WidgetRef ref) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.language,
            color: Colors.white.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'L\'aperçu intégré n\'est disponible que sur la version web '
            'du portfolio.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openExternally(ref),
            icon: const Icon(Icons.open_in_new),
            label: Text('Ouvrir ${project.title}'),
          ),
        ]));
  }
}
