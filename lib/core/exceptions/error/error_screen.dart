import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart'; // facultatif, pour une animation fluide

class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: Center(
        child: ResponsiveBox(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation Lottie
                Lottie.asset(
                  'assets/animations/error.json',
                  width: 200,
                  repeat: false,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error_outline,
                      size: 96, color: Colors.redAccent),
                ),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.l,
                ),

                ResponsiveText.bodyMedium(
                  'Oups ! Quelque chose s’est mal passé...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.m,
                ),

                ResponsiveText.bodyMedium(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.l,
                ),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (onRetry != null)
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const ResponsiveText.bodyMedium('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (onGoHome != null)
                      OutlinedButton.icon(
                        onPressed: onGoHome,
                        icon: const Icon(Icons.home),
                        label: const ResponsiveText.bodyMedium(
                            'Retour à l’accueil'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),

                const ResponsiveBox(
                  paddingSize: ResponsiveSpacing.m,
                ),

                // Détails techniques (optionnel, affiché uniquement en debug)
                if (!isReleaseMode)
                  ExpansionTile(
                    title:
                        const ResponsiveText.bodyMedium('Détails techniques'),
                    children: [
                      SelectableText(
                        stackTrace?.toString() ?? 'Aucune stacktrace',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get isReleaseMode {
    var inRelease = true;
    assert(() {
      inRelease = false;
      return true;
    }());
    return inRelease;
  }
}
