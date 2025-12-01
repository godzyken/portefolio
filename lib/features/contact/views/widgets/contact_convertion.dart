import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/contact/services/google_calendar_service.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/cv_download_provider.dart';

class ContactConversionOption extends ConsumerWidget {
  final ResponsiveInfo info;
  final ThemeData theme;

  const ContactConversionOption(
      {super.key, required this.info, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBox(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: info.isMobile ? 24 : 64,
        vertical: 32,
      ),
      marginSize: info.isMobile ? ResponsiveSpacing.m : ResponsiveSpacing.l,
      padding: EdgeInsets.all(info.isMobile ? 24 : 40),
      paddingSize: info.isMobile ? ResponsiveSpacing.m : ResponsiveSpacing.l,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline,
              size: 48, color: theme.colorScheme.primary),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          ResponsiveText.bodySmall(
            'Vous avez une idée de projet ?',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
          ResponsiveText.bodySmall(
            'Discutons-en autour d\'un café virtuel ou réel',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildGoogleCalendarChip(theme, ref, context),
              _buildCvActionChip(theme, ref, context),
            ],
          ),
        ],
      ),
    );
  }

  /// Chip pour Google Calendar avec DateTimePicker
  Widget _buildGoogleCalendarChip(
    ThemeData theme,
    WidgetRef ref,
    BuildContext context,
  ) {
    final asyncApi = ref.watch(googleCalendarNotifierProvider);

    return asyncApi.when(
      // Si on a déjà l'API, on propose directement de créer un évènement
      data: (calendarService) {
        if (calendarService == null) {
          // Pas encore authentifié : bouton pour démarrer l'authentification
          return _buildActionChip(
            theme,
            Icons.calendar_today,
            'Connecter Google Calendar',
            () async {
              developer.log('🔐 Tentative de connexion...');

              _showLoadingSnackBar(context, 'Connexion en cours...');

              try {
                await ref
                    .read(googleCalendarNotifierProvider.notifier)
                    .signInAndInit();

                if (context.mounted) {
                  _showSuccessSnackBar(context, 'Connecté avec succès !');
                }
              } catch (e) {
                developer.log('❌ Erreur: $e');
                if (context.mounted) {
                  _showErrorSnackBar(context, e.toString());
                }
              }
            },
          );
        }

        return _buildActionChip(
          theme,
          Icons.calendar_today,
          'Réserver un créneau',
          () => _createCalendarEvent(context, ref, calendarService),
        );
      },
      loading: () => _buildActionChip(
          theme, Icons.hourglass_empty, 'Chargement...', () {}),
      error: (err, _) => _buildActionChip(
        theme,
        Icons.error,
        'Erreur Calendar',
        () async {
          await ref
              .read(googleCalendarNotifierProvider.notifier)
              .signInAndInit();
        },
      ),
    );
  }

  /// Créer un événement calendar
  Future<void> _createCalendarEvent(
    BuildContext context,
    WidgetRef ref,
    GoogleCalendarService api,
  ) async {
    try {
      // Sélection date
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        helpText: 'Choisir une date',
        cancelText: 'Annuler',
        confirmText: 'Suivant',
      );

      if (date == null || !context.mounted) return;

      // Sélection heure
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
        helpText: 'Choisir une heure',
        cancelText: 'Annuler',
        confirmText: 'Créer',
      );

      if (time == null || !context.mounted) return;

      // Créer l'événement
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      final end = start.add(const Duration(hours: 1));

      developer.log('📅 Création événement: ${start.toIso8601String()}');

      await api.createEvent(
        summary: 'Discussion avec Emryck Doré',
        description: 'Café virtuel pour parler de votre projet',
        start: start,
        end: end,
      );

      developer.log('✅ Événement créé');

      if (context.mounted) {
        _showSuccessSnackBar(
          context,
          'Événement créé le ${_formatDate(start)} à ${time.format(context)}',
        );
      }
    } catch (e) {
      developer.log('❌ Erreur création: $e');
      if (context.mounted) {
        _showErrorSnackBar(
            context, 'Impossible de créer l\'événement. Erreur: $e');
      }
    }
  }

  /// Chip pour CV avec Riverpod safe
  Widget _buildCvActionChip(
      ThemeData theme, WidgetRef ref, BuildContext context) {
    final cvUrlAsync = ref.watch(cvUrlProvider);
    final isAvailableAsync = ref.watch(isCvAvailableProvider);

    if (cvUrlAsync.isEmpty || isAvailableAsync != true) {
      return _buildActionChip(
        theme,
        Icons.hourglass_empty,
        'CV en cours de chargement...',
        () {},
      );
    }

    final cvService = ref.read(cvDownloadServiceProvider);

    return _buildActionChip(
      theme,
      Icons.download,
      'Télécharger mon CV',
      () => cvService.downloadCv(context, cvUrlAsync),
    );
  }

  /// Chip helper
  Widget _buildActionChip(
      ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, color: theme.colorScheme.primary),
      label: ResponsiveText.headlineMedium(label),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      labelStyle:
          theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  /// Helpers pour les SnackBars
  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const ResponsiveBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            ResponsiveText.headlineMedium(message),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            Expanded(child: ResponsiveText.bodyMedium(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            Expanded(child: ResponsiveText.bodySmall('Erreur: $error')),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
