import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/widgets/responsive_text.dart';

/// Bannière incitant à passer le diagnostic de maturité numérique,
/// affichée sur la home page ("le wow" évoqué dans la refonte du portfolio).
class DiagnosticTeaserBanner extends StatelessWidget {
  const DiagnosticTeaserBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.go('/diagnostic'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.25),
              theme.colorScheme.secondary.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.insights, color: theme.colorScheme.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveText.titleSmall(
                    'Évaluez votre maturité numérique',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const ResponsiveText.bodySmall(
                    'Diagnostic gratuit en 3 minutes, résultat immédiat.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
