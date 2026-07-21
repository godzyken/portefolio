import 'package:flutter/material.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../data/iot_tools_data.dart';

/// Catalogue vitrine des outils IoT utilisés sur les chantiers
///
/// Complète le dashboard temps réel en donnant une vue d'ensemble
/// pédagogique de l'écosystème IoT chantier (asset tracking, wearables,
/// capteurs environnementaux, connectivité, plateformes, BIM…).
class IoTToolsCatalog extends StatelessWidget {
  final ResponsiveInfo info;

  const IoTToolsCatalog({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 1;
    if (info.size.width > 1100) {
      crossAxisCount = 3;
    } else if (info.size.width > 700) {
      crossAxisCount = 2;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            'Écosystème IoT sur un chantier de construction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ResponsiveText(
            'Panorama des familles d\'outils connectés qui alimentent ce '
                'type de dashboard : de la localisation d\'engins à la '
                'remontée d\'alertes, en passant par la connectivité et '
                'l\'intégration BIM.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kIoTToolCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: info.isMobile ? 2.6 : 2.2,
            ),
            itemBuilder: (context, index) {
              final tool = kIoTToolCategories[index];
              return _IoTToolCard(tool: tool);
            },
          ),
        ],
      ),
    );
  }
}

class _IoTToolCard extends StatelessWidget {
  final IoTToolCategory tool;

  const _IoTToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tool.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tool.color.withValues(alpha: 0.15),
            ),
            child: Icon(tool.icon, color: tool.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText.displaySmall(
                  '${tool.index}. ${tool.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tool.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}