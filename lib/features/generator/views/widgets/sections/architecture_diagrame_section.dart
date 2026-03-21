import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../experience/data/experiences_data.dart';
import '../../../../projets/data/project_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mapping : tag → service externe reconnu
// ─────────────────────────────────────────────────────────────────────────────

const _kServiceTags = {
  'supabase': _ArchNode('Supabase', 'BDD · Auth · API', _NodeColor.teal),
  'googlemaps':
      _ArchNode('Google Maps', 'Cartes · Navigation', _NodeColor.teal),
  'googlemap': _ArchNode('Google Maps', 'Cartes · Navigation', _NodeColor.teal),
  'tawkto': _ArchNode('Tawk.to', 'Chat · Support', _NodeColor.teal),
  'firebase': _ArchNode('Firebase', 'BDD · Auth · Storage', _NodeColor.teal),
  'emailjs': _ArchNode('EmailJS', 'Envoi emails', _NodeColor.teal),
  'stripe': _ArchNode('Stripe', 'Paiements', _NodeColor.teal),
  'onesignal': _ArchNode('OneSignal', 'Notifications push', _NodeColor.teal),
  'mqtt': _ArchNode('MQTT Broker', 'IoT messaging', _NodeColor.teal),
  'influxdb': _ArchNode('InfluxDB', 'Séries temporelles', _NodeColor.teal),
  'grafana': _ArchNode('Grafana', 'Dashboards', _NodeColor.teal),
  'postgis': _ArchNode('PostGIS', 'Géodonnées', _NodeColor.teal),
  'mapbox': _ArchNode('Mapbox', 'Cartes vectorielles', _NodeColor.teal),
  'openstreetmap': _ArchNode('OpenStreetMap', 'Données carto', _NodeColor.teal),
  'wakatime': _ArchNode('WakaTime', 'Analytics dev', _NodeColor.teal),
  'wordpress': _ArchNode('WordPress', 'CMS · Backend', _NodeColor.teal),
  'prestashop': _ArchNode('PrestaShop', 'E-commerce', _NodeColor.teal),
  'capacitorjs': _ArchNode('Capacitor', 'Natif mobile', _NodeColor.teal),
};

// Mapping stack → couche UI
const _kFrontendKeywords = {
  'flutter',
  'dart',
  'react',
  'vue',
  'angular',
  'html',
  'css',
  'typescript',
  'javascript',
  'ionic',
};
const _kStateKeywords = {
  'riverpod',
  'riverpod3',
  'bloc',
  'provider',
  'getx',
  'mobx',
  'redux',
  'context',
};
const _kBackendKeywords = {
  'node',
  'nodejs',
  'express',
  'laravel',
  'php',
  'python',
  'fastapi',
  'django',
  'java',
  'spring',
  'go',
  'rust',
  'graphql',
  'rest',
};
const _kStorageKeywords = {
  'postgresql',
  'mysql',
  'mongodb',
  'sqlite',
  'hive',
  'sharedpreferences',
  'redis',
  'elasticsearch',
};

enum _NodeColor { purple, teal, gray, coral }

// ─────────────────────────────────────────────────────────────────────────────
// Modèle de nœud
// ─────────────────────────────────────────────────────────────────────────────

class _ArchNode {
  final String label;
  final String subtitle;
  final _NodeColor color;
  const _ArchNode(this.label, this.subtitle, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────
// Modèle de diagramme
// ─────────────────────────────────────────────────────────────────────────────

class _ArchDiagram {
  final String appName;
  final List<String> platforms;
  final List<String> frontendTechs;
  final List<String> stateTechs;
  final List<String> backendTechs;
  final List<_ArchNode> externalServices;
  final List<String> storageTechs;

  const _ArchDiagram({
    required this.appName,
    required this.platforms,
    required this.frontendTechs,
    required this.stateTechs,
    required this.backendTechs,
    required this.externalServices,
    required this.storageTechs,
  });

  bool get hasState => stateTechs.isNotEmpty;
  bool get hasBackend => backendTechs.isNotEmpty;
  bool get hasServices => externalServices.isNotEmpty;
  bool get hasStorage => storageTechs.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// Builder : construit le modèle à partir de l'expérience + projet optionnel
// ─────────────────────────────────────────────────────────────────────────────

_ArchDiagram _buildDiagram(Experience exp, ProjectInfo? project) {
  // Toutes les techs : tags + clés de stack
  final allTags = [
    ...exp.tags.map((t) => t.toLowerCase()),
    ...(exp.stack as Map)
        .values
        .whereType<List>()
        .expand((l) => l)
        .map((e) => e.toString().toLowerCase()),
  ];

  // Plateformes
  final platforms = (project?.platform ?? []).isNotEmpty
      ? project!.platform!
      : _inferPlatforms(allTags);

  // Couches
  final frontend =
      allTags.where((t) => _kFrontendKeywords.contains(t)).toSet().toList();
  final state =
      allTags.where((t) => _kStateKeywords.contains(t)).toSet().toList();
  final backend =
      allTags.where((t) => _kBackendKeywords.contains(t)).toSet().toList();
  final storage =
      allTags.where((t) => _kStorageKeywords.contains(t)).toSet().toList();

  // Services externes (dédupliqués par label)
  final seenLabels = <String>{};
  final services = allTags
      .map((t) => _kServiceTags[t])
      .whereType<_ArchNode>()
      .where((n) => seenLabels.add(n.label))
      .toList();

  // Si aucune tech frontend explicite, on met le nom du projet
  final frontendDisplay = frontend.isEmpty
      ? [
          exp.tags.firstWhere(
            (t) =>
                _kFrontendKeywords.contains(t.toLowerCase()) ||
                t.toLowerCase() == 'flutter',
            orElse: () => 'Application',
          )
        ]
      : frontend;

  return _ArchDiagram(
    appName: exp.entreprise,
    platforms: platforms,
    frontendTechs: frontendDisplay.take(3).toList(),
    stateTechs: state.take(2).toList(),
    backendTechs: backend.take(2).toList(),
    externalServices: services.take(4).toList(),
    storageTechs: storage.take(2).toList(),
  );
}

List<String> _inferPlatforms(List<String> tags) {
  final result = <String>[];
  if (tags.any(
      (t) => ['flutter', 'dart', 'mobile', 'android', 'ios'].contains(t))) {
    result.add('Mobile');
  }
  if (tags.any((t) => ['web', 'html', 'angular', 'react', 'vue'].contains(t))) {
    result.add('Web');
  }
  if (tags.any((t) => ['desktop', 'windows', 'macos', 'linux'].contains(t))) {
    result.add('Desktop');
  }
  return result.isEmpty ? ['Multi-plateforme'] : result;
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur SVG
// ─────────────────────────────────────────────────────────────────────────────

String _generateSvg(_ArchDiagram d, bool isDark) {
  const w = 680.0;
  const rowH = 56.0;
  const rowGap = 16.0;
  const outerPad = 20.0;
  const innerX = 60.0;
  const innerW = 560.0;

  // 1. Définition des couleurs selon le thème (Inline)
  final outerBg = isDark ? '#2C2C2A' : '#F8F7F4';
  final outerStroke = isDark ? '#5F5E5A' : '#D3D1C7';
  final arrowColor = isDark ? '#888780' : '#B4B2A9';
  final mainTitleColor = isDark ? '#D3D1C7' : '#444441';
  final subTitleColor = isDark ? '#B4B2A9' : '#5F5E5A';

  // Helper pour obtenir les styles d'un nœud selon sa couleur et le thème
  (String bg, String stroke, String txt, String sub) _getStyles(_NodeColor c) {
    if (isDark) {
      return switch (c) {
        _NodeColor.purple => ('#3C3489', '#AFA9EC', '#CECBF6', '#AFA9EC'),
        _NodeColor.teal => ('#085041', '#5DCAA5', '#9FE1CB', '#5DCAA5'),
        _NodeColor.coral => ('#712B13', '#F0997B', '#F5C4B3', '#F0997B'),
        _NodeColor.gray => ('#444441', '#B4B2A9', '#D3D1C7', '#B4B2A9'),
      };
    } else {
      return switch (c) {
        _NodeColor.purple => ('#EEEDFE', '#534AB7', '#3C3489', '#534AB7'),
        _NodeColor.teal => ('#E1F5EE', '#0F6E56', '#085041', '#0F6E56'),
        _NodeColor.coral => ('#FAECE7', '#993C1D', '#712B13', '#993C1D'),
        _NodeColor.gray => ('#F1EFE8', '#5F5E5A', '#444441', '#5F5E5A'),
      };
    }
  }

  // Helper pour dessiner une flèche compatible (sans marker)
  String _drawArrow(double x1, double y1, double x2, double y2, String color) {
    return '''
      <line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="$color" stroke-width="1" />
      <path d="M ${x2 - 4} ${y2 - 6} L $x2 $y2 L ${x2 + 4} ${y2 - 6}" fill="none" stroke="$color" stroke-width="1" stroke-linecap="round" />
    ''';
  }

  // Calcule la hauteur totale
  var curY = outerPad + 46.0;
  curY += rowH + rowGap; // Users
  curY += rowH + rowGap; // Frontend
  if (d.hasState) curY += rowH + rowGap;
  if (d.hasBackend) curY += rowH + rowGap;
  if (d.hasServices) curY += rowH + rowGap;
  if (d.hasStorage) curY += rowH + rowGap;
  final outerH = curY + outerPad;

  final buf = StringBuffer();
  buf.writeln(
      '<svg width="$w" height="${outerH + 20}" viewBox="0 0 $w ${outerH + 20}" xmlns="http://www.w3.org/2000/svg">');

  // Container extérieur
  buf.writeln(
      '<rect x="20" y="10" width="${w - 40}" height="$outerH" rx="16" fill="$outerBg" stroke="$outerStroke" stroke-width="0.5"/>');

  // Titre et Plateformes
  buf.writeln(_text(
      w / 2, 36, _truncate(d.appName, 24), mainTitleColor, 'middle', true));
  buf.writeln(_text(
      w / 2, 53, d.platforms.join(' · '), subTitleColor, 'middle', false,
      size: 11));

  double y = 10 + outerPad + 46;

  // ── Utilisateurs ──
  final userStyle = _getStyles(_NodeColor.gray);
  buf.writeln(_rowInline(y, innerX, innerW, rowH, userStyle, 'Utilisateurs',
      'Clients · Techniciens · Admin'));
  y += rowH + rowGap;

  // ── Flèche vers Frontend ──
  buf.write(_drawArrow(w / 2, y - rowGap, w / 2, y, arrowColor));

  // ── Frontend ──
  final feStyle = _getStyles(_NodeColor.purple);
  buf.writeln(_rowInline(y, innerX, innerW, rowH, feStyle, 'Frontend',
      d.frontendTechs.join(' · ')));
  y += rowH + rowGap;

  // ── State Management ──
  if (d.hasState) {
    buf.write(_drawArrow(w / 2, y - rowGap, w / 2, y, feStyle.$2));
    buf.writeln(_rowInline(y, innerX, innerW, rowH, feStyle, 'State Management',
        d.stateTechs.join(' · ')));
    y += rowH + rowGap;
  }

  // ── Backend ──
  if (d.hasBackend) {
    buf.write(_drawArrow(w / 2, y - rowGap, w / 2, y, feStyle.$2));
    buf.writeln(_rowInline(y, innerX, innerW, rowH, feStyle, 'Services Core',
        d.backendTechs.join(' · ')));
    y += rowH + rowGap;
  }

  // ── Services Externes ──
  if (d.hasServices) {
    final n = d.externalServices.length;
    final gap = 12.0;
    final boxW = (innerW - gap * (n - 1)) / n;
    final serviceColor = isDark ? '#5DCAA5' : '#1D9E75';

    for (var i = 0; i < n; i++) {
      final cx = innerX + boxW / 2 + i * (boxW + gap);
      final midY = y - rowGap / 2;
      buf.write(
          '<path d="M ${w / 2} ${y - rowGap} L ${w / 2} $midY L $cx $midY L $cx $y" fill="none" stroke="$serviceColor" stroke-width="1" />');
      buf.write(
          '<path d="M ${cx - 4} ${y - 6} L $cx $y L ${cx + 4} ${y - 6}" fill="none" stroke="$serviceColor" stroke-width="1" />');

      final node = d.externalServices[i];
      buf.writeln(_rowInline(y, innerX + i * (boxW + gap), boxW, rowH,
          _getStyles(node.color), node.label, node.subtitle));
    }
    y += rowH + rowGap;
  }

  // ── Stockage ──
  if (d.hasStorage) {
    buf.write(_drawArrow(w / 2, y - rowGap, w / 2, y, arrowColor));
    buf.writeln(_rowInline(y, innerX, innerW, rowH, userStyle, 'Stockage',
        d.storageTechs.join(' · ')));
  }

  buf.writeln('</svg>');
  return buf.toString();
}

// Helpers avec styles INLINE obligatoires pour flutter_svg
String _rowInline(double y, double x, double w, double h,
    (String, String, String, String) s, String title, String sub) {
  final cx = x + w / 2;
  return '''
    <rect x="$x" y="$y" width="$w" height="$h" rx="8" fill="${s.$1}" stroke="${s.$2}" stroke-width="0.5"/>
    ${_text(cx, y + h * 0.38, _truncate(title, 30), s.$3, 'middle', true)}
    ${sub.isNotEmpty ? _text(cx, y + h * 0.68, _truncate(sub, 50), s.$4, 'middle', false, size: 11) : ''}
  ''';
}

String _text(
    double x, double y, String content, String color, String anchor, bool bold,
    {double size = 13}) {
  final weight = bold ? 'font-weight="500"' : '';
  return '<text x="$x" y="$y" text-anchor="$anchor" dominant-baseline="central" fill="$color" font-family="sans-serif" font-size="$size" $weight>$content</text>';
}
// ─────────────────────────────────────────────────────────────────────────────
// Helpers SVG
// ─────────────────────────────────────────────────────────────────────────────

/*String _row(double y, double x, double w, double h, String bgCls,
    String textCls, String subCls, String title, String sub) {
  final cx = x + w / 2;
  final ty = y + h * 0.38;
  final sy = y + h * 0.68;

  return '''
    <rect class="$bgCls" x="$x" y="$y" width="$w" height="$h" rx="8" stroke-width="0.5"/>
    
    ${_text(cx, ty, _truncate(title, 30), textCls, 'middle', true)}
    
    ${sub.isNotEmpty ? _text(cx, sy, _truncate(sub, 50), subCls, 'middle', false, size: 11) : ''}
  ''';
}

String _arrow(double x, double y1, double y2, String stroke) =>
    '<line x1="$x" y1="$y1" x2="$x" y2="$y2" '
    'stroke="$stroke" stroke-width="1" marker-end="url(#arr)"/>';*/

String _truncate(String s, int max) =>
    s.length > max ? '${s.substring(0, max - 1)}…' : s;

/*
(String, String, String) _colorClass(_NodeColor c) => switch (c) {
      _NodeColor.purple => ('lp', 'lpt', 'lps'),
      _NodeColor.teal => ('lt', 'ltt', 'lts'),
      _NodeColor.coral => ('lc', 'lct', 'lcs'),
      _NodeColor.gray => ('lg', 'lgt', 'lgs'),
    };
*/

// ─────────────────────────────────────────────────────────────────────────────
// Widget Flutter
// ─────────────────────────────────────────────────────────────────────────────

class ArchitectureDiagramSection extends ConsumerWidget {
  final Experience experience;
  final ProjectInfo? project;

  const ArchitectureDiagramSection({
    super.key,
    required this.experience,
    this.project,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diagram = _buildDiagram(experience, project);
    final svgString = _generateSvg(diagram, isDark);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Architecture systeme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Diagramme SVG
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: SvgPicture.string(
              svgString,
              fit: BoxFit.contain,
            ),
          ),

          // Légende des couches
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendBadge(label: 'UI / Frontend', color: Color(0xFF7F77DD)),
        _LegendBadge(label: 'Services externes', color: Color(0xFF1D9E75)),
        _LegendBadge(label: 'Infra / Stockage', color: Color(0xFF888780)),
      ],
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
