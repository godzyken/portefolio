import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../../../../core/affichage/screen_size_detector.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/cv_download_provider.dart';

class ContactConversionOption extends ConsumerWidget {
  final ResponsiveInfo info;
  final ThemeData theme;

  const ContactConversionOption(
      {super.key, required this.info, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: info.isMobile ? 24 : 64,
        vertical: 32,
      ),
      padding: EdgeInsets.all(info.isMobile ? 24 : 40),
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
          const SizedBox(height: 16),
          Text(
            'Vous avez une idée de projet ?',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Discutons-en autour d\'un café virtuel ou réel',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
      data: (calendarApi) {
        if (calendarApi == null) {
          // Pas encore authentifié : bouton pour démarrer l'authentification
          return _buildActionChip(
            theme,
            Icons.calendar_today,
            'Connecter Google Calendar',
            () async {
              // Lancement de l'auth (doit être déclenché par un clic utilisateur)
              await ref
                  .read(googleCalendarNotifierProvider.notifier)
                  .signInAndInit();
            },
          );
        }

        // Authentifié : bouton pour choisir date/heure et créer l'évènement
        return _buildActionChip(
          theme,
          Icons.calendar_today,
          'Réserver un créneau',
          () async {
            try {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date == null) return;
              if (!context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 10, minute: 0),
              );
              if (time == null) return;

              final start = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              final end = start.add(const Duration(hours: 1));

              final event = calendar.Event()
                ..summary = 'Discussion avec Emryck alias Ryo Saeba'
                ..description =
                    'Café virtuel ou réel pour parler de votre projet'
                ..start =
                    calendar.EventDateTime(dateTime: start, timeZone: 'UTC')
                ..end = calendar.EventDateTime(dateTime: end, timeZone: 'UTC');

              final createdEvent =
                  await calendarApi.events.insert(event, 'primary');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Événement créé : ${createdEvent.summary}')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de la création : $e')),
                );
              }
            }
          },
        );
      },
      loading: () => _buildActionChip(
          theme, Icons.hourglass_empty, 'Chargement...', () {}),
      error: (err, _) => _buildActionChip(
        theme,
        Icons.error,
        'Erreur Calendar',
        () async {
          // Retry / debug : relancer l'auth si l'utilisateur veut réessayer
          await ref
              .read(googleCalendarNotifierProvider.notifier)
              .signInAndInit();
        },
      ),
    );
  }

  /// Chip pour CV avec Riverpod safe
  Widget _buildCvActionChip(
      ThemeData theme, WidgetRef ref, BuildContext context) {
    final cvUrlAsync = ref.watch(cvUrlProvider);
    final isAvailableAsync = ref.watch(isCvAvailableProvider);

    if (cvUrlAsync == null || isAvailableAsync != true) {
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
      label: Text(label),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      labelStyle:
          theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
