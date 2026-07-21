import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/provider/business_plan_provider.dart';
import '../../../../../core/ui/widgets/responsive_text.dart';



/// Section de chiffres clés animés (compteurs qui montent), alimentée par
/// [businessPlanStatsProvider] — donc par `business_plan.json`.
class AnimatedStatsSection extends ConsumerWidget {
  const AnimatedStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final planLoaded = ref.watch(businessPlanProvider).hasValue;
    final stats = ref.watch(businessPlanStatsProvider);

    if (!planLoaded) return const SizedBox.shrink();

    final items = <_StatItem>[
      _StatItem(
        icon: Icons.design_services_outlined,
        value: stats.servicesCount,
        suffix: '',
        label: 'Domaines d\'accompagnement',
        color: theme.colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.apartment_outlined,
        value: stats.clientTypesCount,
        suffix: '',
        label: 'Types d\'organisations accompagnées',
        color: theme.colorScheme.secondary,
      ),
      _StatItem(
        icon: Icons.workspace_premium_outlined,
        value: stats.expertiseCount,
        suffix: '',
        label: 'Compétences maîtrisées',
        color: theme.colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.trending_up_outlined,
        value: stats.averageExpertiseLevel,
        suffix: '%',
        label: 'Niveau d\'expertise moyen',
        color: theme.colorScheme.secondary,
      ),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 24,
      children: items.map((item) => _AnimatedStatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final int value;
  final String suffix;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
    required this.color,
  });
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withValues(alpha: 0.18),
            item.color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: item.color, size: 28),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: item.value.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                '+${value.round()}${item.suffix}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ResponsiveText.bodySmall(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}