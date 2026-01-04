import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/contact_form_provider.dart';
import '../../providers/cv_download_provider.dart';
import 'calendar_dialog.dart';

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
    final contactForm = ref.watch(contactFormProvider);

    return asyncApi.when(
      data: (calendarService) {
        if (calendarService == null) {
          return _buildActionChip(
            theme,
            Icons.calendar_today,
            'Voir mon Calendrier',
            () async {
              developer.log('🔐 Tentative de connexion...');

              SnackBarHelper.showLoading(context, 'Connexion en cours...');

              try {
                await ref
                    .read(googleCalendarNotifierProvider.notifier)
                    .signInAndInit();

                if (context.mounted) {
                  SnackBarHelper.showSuccess(context, 'Connecté avec succès !');

                  await Future.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    _showCalendarDialogWithContactInfo(
                        context, ref, contactForm);
                  }
                }
              } catch (e) {
                developer.log('❌ Erreur: $e');
                if (context.mounted) {
                  SnackBarHelper.showError(context, e.toString());
                }
              }
            },
          );
        }

        return _buildActionChip(
          theme,
          Icons.event_available,
          'Réserver un créneau',
          () => _showCalendarDialogWithContactInfo(context, ref, contactForm),
        );
      },
      loading: () => _buildActionChip(
          theme, Icons.hourglass_empty, 'Chargement...', () {}),
      error: (err, _) => _buildActionChip(
        theme,
        Icons.error,
        'Réessayer la connexion',
        () async {
          await ref
              .read(googleCalendarNotifierProvider.notifier)
              .signInAndInit();

          if (context.mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              _showCalendarDialogWithContactInfo(context, ref, contactForm);
            }
          }
        },
      ),
    );
  }

  void _showCalendarDialogWithContactInfo(
    BuildContext context,
    WidgetRef ref,
    dynamic contactFormState,
  ) {
    ref.read(appointmentProvider.notifier).setContactInfo(
          contactFormState.name.isNotEmpty ? contactFormState.name : '',
          contactFormState.email.isNotEmpty ? contactFormState.email : '',
          contactFormState.message.isNotEmpty ? contactFormState.message : '',
        );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CalendarDialog(),
    );
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
}
