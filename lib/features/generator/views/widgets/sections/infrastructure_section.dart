import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../services/section_manager.dart';

/// Section Infrastructure - Affiche l'architecture et les données de développement
///
/// Affiche:
/// - Hypothèses du projet
/// - Gains de productivité
/// - Autres gains
/// - Structure des coûts
/// - Synthèse annuelle
class InfrastructureSection extends StatelessWidget {
  final Map<String, dynamic> development;
  final ResponsiveInfo info;

  const InfrastructureSection({
    super.key,
    required this.development,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText.titleMedium(
            '🏗️ Infrastructure & Architecture',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Hypothèses du projet
          if (development.containsKey('1_hypotheses'))
            _InfrastructureDataSection(
              title: '📋 Hypothèses du projet',
              data: development['1_hypotheses'] as Map<String, dynamic>,
              icon: Icons.article_outlined,
              accentColor: Colors.blue,
            ),

          const SizedBox(height: 20),

          // Gains de productivité
          if (development.containsKey('2_gains_productivite'))
            _InfrastructureDataSection(
              title: '⚡ Gains de productivité',
              data: development['2_gains_productivite'] as Map<String, dynamic>,
              icon: Icons.trending_up,
              accentColor: Colors.green,
            ),

          const SizedBox(height: 20),

          // Autres gains
          if (development.containsKey('3_autres_gains'))
            _InfrastructureDataSection(
              title: '💎 Autres gains',
              data: development['3_autres_gains'] as Map<String, dynamic>,
              icon: Icons.emoji_events,
              accentColor: Colors.amber,
            ),

          const SizedBox(height: 20),

          // Coûts
          if (development.containsKey('4_couts'))
            _InfrastructureDataSection(
              title: '💰 Structure des coûts',
              data: development['4_couts'] as Map<String, dynamic>,
              icon: Icons.account_balance_wallet,
              accentColor: Colors.orange,
            ),

          const SizedBox(height: 20),

          // Synthèse annuelle
          if (development.containsKey('5_synthese_annuelle'))
            _SyntheseAnnuelle(
              synthese: development['5_synthese_annuelle'] as List<dynamic>,
              info: info,
            ),
        ],
      ),
    );
  }
}

/// Section de données d'infrastructure (générique)
class _InfrastructureDataSection extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final IconData icon;
  final Color accentColor;

  const _InfrastructureDataSection({
    required this.title,
    required this.data,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SectionBuilder.gradient(
      title: title,
      icon: icon,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return BulletListBuilder(
            items: ['${SectionManager.formatKey(entry.key)}: ${entry.value}'],
            bulletColor: accentColor,
          );
        }).toList(),
      ),
    );
  }
}

/// Synthèse annuelle avec cartes par année
class _SyntheseAnnuelle extends StatelessWidget {
  final List<dynamic> synthese;
  final ResponsiveInfo info;

  const _SyntheseAnnuelle({
    required this.synthese,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return SectionBuilder.gradient(
      title: '📊 Synthèse annuelle',
      icon: Icons.calendar_today,
      accentColor: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: synthese.asMap().entries.map((entry) {
          final index = entry.key;
          final year = entry.value as Map<String, dynamic>;
          return _YearCard(year: year, index: index, info: info);
        }).toList(),
      ),
    );
  }
}

/// Card pour une année de synthèse
class _YearCard extends StatelessWidget {
  final Map<String, dynamic> year;
  final int index;
  final ResponsiveInfo info;

  const _YearCard({
    required this.year,
    required this.index,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.green, Colors.blue, Colors.purple];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleSmall(
            'Année ${year['annee']} - ${year['intervenants']} intervenants',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricColumn(
                  label: 'Gains',
                  value: '${year['gains']}€',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Coûts',
                  value: '${year['couts']}€',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Net',
                  value: '${year['resultat_net']}€',
                  color: color,
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'ROI',
                  value: year['roi'],
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
