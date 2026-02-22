import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimation(),
                const SizedBox(height: 24),
                ResponsiveText.titleLarge(
                  'Oups ! Quelque chose s\'est mal passé…',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ResponsiveText.bodyMedium(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    if (onRetry != null)
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    if (onGoHome != null)
                      OutlinedButton.icon(
                        onPressed: onGoHome,
                        icon: const Icon(Icons.home),
                        label: const Text('Retour à l\'accueil'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                  ],
                ),
                // Détails techniques — debug uniquement
                if (!kReleaseMode) ...[
                  const SizedBox(height: 24),
                  ExpansionTile(
                    title: const Text('Détails techniques',
                        style: TextStyle(fontSize: 13)),
                    children: [
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            stackTrace?.toString() ??
                                'Aucune stacktrace disponible',
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    // ✅ Pas de developer.log() ici — l'UI n'est pas responsable du logging
    try {
      return Lottie.asset(
        'assets/images/animations/error.json',
        width: 180,
        repeat: false,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.error_outline, size: 96, color: Colors.redAccent),
      );
    } catch (_) {
      return const Icon(Icons.error_outline, size: 96, color: Colors.redAccent);
    }
  }
}
