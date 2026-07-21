import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/provider/business_plan_provider.dart';
import '../../../../../core/ui/sections/section_system.dart';
import '../../../../../core/ui/widgets/responsive_text.dart';



/// Section storytelling de la home : "votre quotidien aujourd'hui" (douleur)
/// → "notre vision" → positionnement → appel à l'action.
///
/// Tout le texte vient de `business_plan.json` (via [businessPlanProvider]) :
/// modifier le JSON suffit à faire évoluer le discours, sans recompiler.
class BusinessStorySection extends ConsumerWidget {
  const BusinessStorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final planAsync = ref.watch(businessPlanProvider);
    final plan = planAsync.asData?.value;

    // Tant que le JSON n'est pas chargé (quasi instantané, asset bundlé),
    // on n'affiche rien plutôt qu'un texte statique dupliqué à maintenir.
    if (plan == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PositioningRoles(roles: plan.positioning.roles, theme: theme),
        const SizedBox(height: 24),
        SectionBuilder.borderless(
          title: 'Votre quotidien aujourd\'hui',
          icon: Icons.warning_amber_rounded,
          child: ResponsiveText.bodyMedium(
            plan.market.problem,
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Icon(
            Icons.south_rounded,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        SectionBuilder.gradient(
          title: plan.vision.title,
          icon: Icons.lightbulb_outline,
          accentColor: theme.colorScheme.primary,
          child: ResponsiveText.bodyMedium(
            plan.vision.content,
            style: const TextStyle(color: Colors.white, height: 1.6),
          ),
        ),
        const SizedBox(height: 24),
        SectionBuilder.simple(
          title: 'Pourquoi nous faire confiance',
          icon: Icons.verified_outlined,
          accentColor: theme.colorScheme.secondary,
          child: BulletListBuilder.checks(
            items: plan.competitiveAdvantages.take(4).toList(),
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        _StoryCta(theme: theme),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0);
  }
}

class _PositioningRoles extends StatelessWidget {
  const _PositioningRoles({required this.roles, required this.theme});

  final List<String> roles;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: roles.map((role) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.35)),
          ),
          child: ResponsiveText.bodySmall(
            role,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StoryCta extends StatelessWidget {
  const _StoryCta({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        FilledButton.icon(
          onPressed: () => context.go('/diagnostic'),
          icon: const Icon(Icons.route_outlined),
          label: const Text('Découvrir notre méthode'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/contact'),
          icon: Icon(Icons.calendar_month_outlined,
              color: theme.colorScheme.onSurface),
          label: const Text('Prendre rendez-vous'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            side: BorderSide(color: theme.colorScheme.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}