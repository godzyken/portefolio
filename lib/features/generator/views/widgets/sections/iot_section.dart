import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../../projets/views/screens/iot_dashboard_screen.dart';
import '../../../../projets/views/screens/iot_tools_catalog.dart';

/// Section IoT - Affiche le dashboard IoT embarqué et le catalogue
/// des outils IoT utilisés sur un chantier
///
/// Deux vues accessibles via un toggle :
/// - "Démo live" : dashboard interactif avec données temps réel
///   (température, vibration, consommation, etc.)
/// - "Écosystème" : panorama pédagogique des familles d'outils IoT
///   chantier (asset tracking, wearables, capteurs environnementaux,
///   connectivité, plateformes, intégration BIM…)
class IoTSection extends StatefulWidget {
  final ResponsiveInfo info;

  const IoTSection({
    super.key,
    required this.info,
  });

  @override
  State<IoTSection> createState() => _IoTSectionState();
}

class _IoTSectionState extends State<IoTSection> {
  bool _showCatalog = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToggle(),
        const SizedBox(height: 12),
        Container(
          height: widget.info.isMobile ? 400 : 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _showCatalog
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF0F172A),
                    child: SingleChildScrollView(
                      child: IoTToolsCatalog(info: widget.info),
                    ),
                  )
                : const EnhancedIotDashboardScreen(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleButton(
              label: 'Démo live',
              icon: LucideIcons.activity,
              isActive: !_showCatalog,
              onTap: () => setState(() => _showCatalog = false),
            ),
            _toggleButton(
              label: 'Écosystème IoT',
              icon: LucideIcons.layout_dashboard,
              isActive: _showCatalog,
              onTap: () => setState(() => _showCatalog = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyan.withValues(alpha: 0.18) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.cyanAccent : Colors.white60,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.white60,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
