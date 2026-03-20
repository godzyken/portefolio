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

  // Définition des couleurs en fonction du thème (plus de CSS)
  final bg = isDark ? '#2C2C2A' : '#F8F7F4';
  final stroke = isDark ? '#5F5E5A' : '#D3D1C7';
  final textColor = isDark ? '#CECBF6' : '#3C3489';
  final subColor = isDark ? '#AFA9EC' : '#534AB7';

  // Pour les lignes (flèches), dessine un petit triangle manuellement au bout
  // Exemple de helper pour une flèche compatible :
  String _drawCompatibleArrow(double x, double y1, double y2, String color) {
    return '''
      <line x1="$x" y1="$y1" x2="$x" y2="$y2" stroke="$color" stroke-width="1" />
      <path d="M ${x - 4} ${y2 - 6} L $x $y2 L ${x + 4} ${y2 - 6}" fill="none" stroke="$color" stroke-width="1" />
    ''';
  }

  // Palette
  const colors = {
    'purple-fill': '#EEEDFE',
    'purple-stroke': '#534AB7',
    'purple-text': '#3C3489',
    'purple-sub': '#534AB7',
    'teal-fill': '#E1F5EE',
    'teal-stroke': '#0F6E56',
    'teal-text': '#085041',
    'teal-sub': '#0F6E56',
    'gray-fill': '#F1EFE8',
    'gray-stroke': '#5F5E5A',
    'gray-text': '#444441',
    'gray-sub': '#5F5E5A',
    'coral-fill': '#FAECE7',
    'coral-stroke': '#993C1D',
    'coral-text': '#712B13',
    'coral-sub': '#993C1D',
    'dark-purple-fill': '#3C3489',
    'dark-purple-stroke': '#AFA9EC',
    'dark-purple-text': '#CECBF6',
    'dark-purple-sub': '#AFA9EC',
    'dark-teal-fill': '#085041',
    'dark-teal-stroke': '#5DCAA5',
    'dark-teal-text': '#9FE1CB',
    'dark-teal-sub': '#5DCAA5',
    'dark-gray-fill': '#444441',
    'dark-gray-stroke': '#B4B2A9',
    'dark-gray-text': '#D3D1C7',
    'dark-gray-sub': '#B4B2A9',
  };

  // Calcule la hauteur totale
  var curY = outerPad + 40.0; // after outer header
  // users row
  curY += rowH + rowGap;
  // frontend
  curY += rowH + rowGap;
  // state (optional)
  if (d.hasState) curY += rowH + rowGap;
  // backend (optional)
  if (d.hasBackend) curY += rowH + rowGap;
  // services (optional)
  if (d.hasServices) curY += rowH + rowGap;
  // storage (optional)
  if (d.hasStorage) curY += rowH + rowGap;
  final outerH = curY + outerPad;
  final totalH = outerH + 20;

  final buf = StringBuffer();
  buf.writeln(
      '<svg width="100%" viewBox="0 0 $w $totalH" xmlns="http://www.w3.org/2000/svg">');

  // ── Styles dark-mode ──
  buf.writeln('<style>');
  buf.writeln('@media (prefers-color-scheme:dark){');
  buf.writeln('.lp{fill:#3C3489;stroke:#AFA9EC}');
  buf.writeln('.lpt{fill:#CECBF6}.lps{fill:#AFA9EC}');
  buf.writeln('.lt{fill:#085041;stroke:#5DCAA5}');
  buf.writeln('.ltt{fill:#9FE1CB}.lts{fill:#5DCAA5}');
  buf.writeln('.lg{fill:#444441;stroke:#B4B2A9}');
  buf.writeln('.lgt{fill:#D3D1C7}.lgs{fill:#B4B2A9}');
  buf.writeln('.lc{fill:#712B13;stroke:#F0997B}');
  buf.writeln('.lct{fill:#F5C4B3}.lcs{fill:#F0997B}');
  buf.writeln('.outer{fill:#2C2C2A;stroke:#5F5E5A}');
  buf.writeln('.arrow-line{stroke:#888780}');
  buf.writeln('}');
  buf.writeln('@media (prefers-color-scheme:light){');
  buf.writeln('.lp{fill:#EEEDFE;stroke:#534AB7}');
  buf.writeln('.lpt{fill:#3C3489}.lps{fill:#534AB7}');
  buf.writeln('.lt{fill:#E1F5EE;stroke:#0F6E56}');
  buf.writeln('.ltt{fill:#085041}.lts{fill:#0F6E56}');
  buf.writeln('.lg{fill:#F1EFE8;stroke:#5F5E5A}');
  buf.writeln('.lgt{fill:#444441}.lgs{fill:#5F5E5A}');
  buf.writeln('.lc{fill:#FAECE7;stroke:#993C1D}');
  buf.writeln('.lct{fill:#712B13}.lcs{fill:#993C1D}');
  buf.writeln('.outer{fill:#F8F7F4;stroke:#D3D1C7}');
  buf.writeln('.arrow-line{stroke:#B4B2A9}');
  buf.writeln('}');
  buf.writeln('text{font-family:sans-serif;font-size:13px}');
  buf.writeln('.th{font-weight:500;font-size:13px}.ts{font-size:11px}');
  buf.writeln('</style>');

  // ── Arrow marker ──
  buf.writeln('<defs>'
      '<marker id="arr" viewBox="0 0 10 10" refX="8" refY="5" '
      'markerWidth="6" markerHeight="6" orient="auto-start-reverse">'
      '<path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" '
      'stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>'
      '</marker>'
      '</defs>');

  // ── Container extérieur ──
  buf.writeln('<rect class="outer" x="20" y="10" '
      'width="${w - 40}" height="$outerH" rx="16" stroke-width="0.5"/>');
  // titre container
  final appLabel = _truncate(d.appName, 24);
  buf.writeln(_text(w / 2, 10 + 26, appLabel, 'th lgt', 'middle'));
  // plateformes en petites pills
  final platStr = d.platforms.join(' · ');
  buf.writeln(_text(w / 2, 10 + 43, platStr, 'ts lgs', 'middle'));

  double y = 10 + outerPad + 46;

  // ── Utilisateurs ──
  buf.writeln(_row(y, innerX, innerW, rowH, 'lg', 'lgt', 'lgs', 'Utilisateurs',
      'Clients · Techniciens · Admin'));
  y += rowH + rowGap;

  // ── Arrow ──
  buf.write(_arrow(w / 2, y - rowGap, y, '#888780'));

  // ── Frontend ──
  final feSub = d.frontendTechs.join(' · ');
  buf.writeln(
      _row(y, innerX, innerW, rowH, 'lp', 'lpt', 'lps', 'Frontend', feSub));
  y += rowH + rowGap;

  // ── State management ──
  if (d.hasState) {
    buf.write(_arrow(w / 2, y - rowGap, y, '#7F77DD'));
    final stSub = d.stateTechs.join(' · ');
    buf.writeln(_row(y, innerX, innerW, rowH, 'lp', 'lpt', 'lps',
        'State management', stSub));
    y += rowH + rowGap;
  }

  // ── Backend / Services Core ──
  if (d.hasBackend) {
    buf.write(_arrow(w / 2, y - rowGap, y, '#7F77DD'));
    final bkSub = d.backendTechs.join(' · ');
    buf.writeln(_row(
        y, innerX, innerW, rowH, 'lp', 'lpt', 'lps', 'Services core', bkSub));
    y += rowH + rowGap;
  }

  // ── Services externes (multi-colonnes) ──
  if (d.hasServices) {
    final services = d.externalServices;
    final n = services.length;
    final gap = 12.0;
    final boxW = (innerW - gap * (n - 1)) / n;

    // Flèches descendantes depuis le nœud précédent
    for (var i = 0; i < n; i++) {
      final cx = innerX + boxW / 2 + i * (boxW + gap);
      // L-bend depuis le centre de la ligne précédente
      final prevCx = w / 2;
      final midY = y - rowGap / 2;
      buf.write('<path d="M $prevCx ${y - rowGap} L $prevCx $midY '
          'L $cx $midY L $cx $y" '
          'fill="none" stroke="#1D9E75" stroke-width="1" '
          'marker-end="url(#arr)"/>');
    }

    for (var i = 0; i < n; i++) {
      final sx = innerX + i * (boxW + gap);
      final node = services[i];
      final cls = _colorClass(node.color);
      buf.writeln(_row(y, sx, boxW, rowH, cls.$1, cls.$2, cls.$3, node.label,
          node.subtitle));
    }
    y += rowH + rowGap;
  }

  // ── Stockage ──
  if (d.hasStorage) {
    // Flèches convergentes
    if (d.hasServices) {
      final n = d.externalServices.length;
      final gap = 12.0;
      final boxW = (innerW - gap * (n - 1)) / n;
      final destCx = w / 2;
      final midY = y - rowGap / 2;
      for (var i = 0; i < n; i++) {
        final srcCx = innerX + boxW / 2 + i * (boxW + gap);
        buf.write('<path d="M $srcCx ${y - rowGap} L $srcCx $midY '
            'L $destCx $midY L $destCx $y" '
            'fill="none" stroke="#888780" stroke-width="1" '
            'marker-end="url(#arr)"/>');
      }
    } else {
      buf.write(_arrow(w / 2, y - rowGap, y, '#888780'));
    }
    final stgSub = d.storageTechs.join(' · ');
    buf.writeln(_row(y, innerX, innerW, rowH, 'lg', 'lgt', 'lgs', 'Stockage',
        stgSub.isEmpty ? 'Données persistantes' : stgSub));
    y += rowH + rowGap;
  }

  buf.writeln('</svg>');
  return buf.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers SVG
// ─────────────────────────────────────────────────────────────────────────────

String _row(double y, double x, double w, double h, String bgCls,
    String textCls, String subCls, String title, String sub) {
  final cx = x + w / 2;
  final ty = y + h * 0.38;
  final sy = y + h * 0.68;
  return '<rect class="$bgCls" x="$x" y="$y" width="$w" height="$h" '
      'rx="8" stroke-width="0.5"/>'
      '${_text(cx, ty, _truncate(title, 30), 'th $textCls', 'middle')}'
      '${sub.isNotEmpty ? _text(cx, sy, _truncate(sub, 50), 'ts $subCls', 'middle') : ''}';
}

String _text(double x, double y, String content, String cls, String anchor) =>
    '<text x="$x" y="$y" text-anchor="$anchor" '
    'dominant-baseline="central" class="$cls">$content</text>';

String _arrow(double x, double y1, double y2, String stroke) =>
    '<line x1="$x" y1="$y1" x2="$x" y2="$y2" '
    'stroke="$stroke" stroke-width="1" marker-end="url(#arr)"/>';

String _truncate(String s, int max) =>
    s.length > max ? '${s.substring(0, max - 1)}…' : s;

(String, String, String) _colorClass(_NodeColor c) => switch (c) {
      _NodeColor.purple => ('lp', 'lpt', 'lps'),
      _NodeColor.teal => ('lt', 'ltt', 'lts'),
      _NodeColor.coral => ('lc', 'lct', 'lcs'),
      _NodeColor.gray => ('lg', 'lgt', 'lgs'),
    };

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
