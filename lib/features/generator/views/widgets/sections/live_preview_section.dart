import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/sections/section_system.dart';
import 'package:url_launcher/url_launcher.dart';

import 'live_preview_frame_web.dart'
    if (dart.library.io) 'live_preview_frame_web.dart' as frame_impl;

/// Section "Aperçu en direct" : affiche le site déployé du projet
/// (ex: emap-82.fr sur Netlify) directement dans la fiche projet.
///
/// - Sur le Web : le site est embarqué dans une iframe.
/// - Sur mobile/desktop natif : pas d'iframe HTML disponible, on affiche
///   une carte avec un bouton "Ouvrir le site" (navigateur externe).
///
/// Dans tous les cas, un bouton "Ouvrir dans un nouvel onglet" reste
/// disponible : certains sites refusent d'être affichés en iframe
/// (header X-Frame-Options / CSP frame-ancestors), auquel cas la preview
/// intégrée peut rester blanche — le lien externe est le filet de sécurité.
class LivePreviewSection extends StatelessWidget {
  final String url;
  final String projectTitle;
  final ResponsiveInfo info;

  const LivePreviewSection({
    super.key,
    required this.url,
    required this.projectTitle,
    required this.info,
  });

  Future<void> _openExternally() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hauteur explicite (et non un Expanded) : cette section est insérée
    // dans un Container dont le parent (SectionBuilder) se dimensionne à
    // son contenu, donc une hauteur non bornée y arriverait potentiellement

    final previewHeight = (info.size.height * 0.6).clamp(360.0, 720.0);

    return SectionBuilder.simple(
      title: 'Aperçu en direct',
      icon: Icons.public,
      accentColor: ColorHelpers.chartColors[4],
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(children: [
                  Expanded(
                    child: Text(url,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _openExternally,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Nouvel onglet'),
                  )
                ])),
            SizedBox(
              height: previewHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb ? _buildIframe() : _buildNativeFallback(context),
              ),
            ),
          ]),
    );
  }

  Widget _buildIframe() {
    return Container(
      color: Colors.white,
      child: frame_impl.buildLivePreviewIframe(url),
    );
  }

  Widget _buildNativeFallback(BuildContext context) {
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
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
            label: Text('Ouvrir $projectTitle'),
          ),
        ]));
  }
}
