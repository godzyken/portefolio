import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';

import '../../../../projets/views/screens/iot_dashboard_screen.dart';

/// Section IoT - Affiche le dashboard IoT embarqué
///
/// Affiche un dashboard interactif pour les projets IoT
/// avec des données temps réel (température, vibration, consommation, etc.)
class IoTSection extends StatelessWidget {
  final ResponsiveInfo info;

  const IoTSection({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: info.isMobile ? 400 : 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const EnhancedIotDashboardScreen(),
      ),
    );
  }
}
