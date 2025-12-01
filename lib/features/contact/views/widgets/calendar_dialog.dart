import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../providers/calendar_provider.dart';
import '../../services/google_calendar_service.dart';

/// Dialog qui affiche le calendrier Google avec les événementsclass
class CalendarDialog extends ConsumerStatefulWidget {
  const CalendarDialog({super.key});

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;

  // Configuration des créneaux disponibles
  final List<TimeOfDay> _availableTimeSlots = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calendarService = ref.watch(googleCalendarServiceProvider);
    final info = ref.watch(responsiveInfoProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ResponsiveBox(
        width: info.size.width > 900 ? 900 : info.size.width * 0.9,
        height: info.size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),

            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return SingleChildScrollView(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 400,
                          child: _buildCalendar(theme),
                        ),
                        Divider(
                          height: 1,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                        ),
                        SizedBox(
                          height: 400,
                          child: _buildTimeSlots(theme, calendarService),
                        ),
                      ],
                    ));
                  }
                  return Row(
                    children: [
                      // Calendrier à gauche
                      Expanded(
                        flex: 3,
                        child: _buildCalendar(theme),
                      ),

                      // Divider
                      VerticalDivider(
                        width: 1,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),

                      // Créneaux horaires à droite
                      Expanded(
                        flex: 2,
                        child: _buildTimeSlots(theme, calendarService),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header du dialog
  Widget _buildHeader(ThemeData theme) {
    return ResponsiveBox(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white, size: 28),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.bodyMedium(
                  'Réserver un rendez-vous',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ResponsiveText.bodySmall(
                  'Sélectionnez une date et un créneau',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  /// Widget du calendrier
  Widget _buildCalendar(ThemeData theme) {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instructions
          ResponsiveBox(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
                const Expanded(
                  child: ResponsiveText.bodySmall(
                    'Choisissez d\'abord une date disponible',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Header du mois avec navigation
          ResponsiveBox(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left,
                      color: theme.colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _focusedMonth =
                          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    });
                  },
                ),
                ResponsiveText.bodyMedium(
                  _getMonthName(_focusedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: theme.colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _focusedMonth =
                          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),

          // Jours de la semaine
          ResponsiveBox(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                final isWeekend = day == 'S' || day == 'D';
                return Expanded(
                  child: Center(
                    child: ResponsiveText.bodySmall(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isWeekend
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendrier
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 semaines maximum
              itemBuilder: (context, index) {
                final dayNumber = index - startingWeekday + 2;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final day = DateTime(
                    _focusedMonth.year, _focusedMonth.month, dayNumber);
                final isToday = _isSameDay(day, DateTime.now());
                final isSelected =
                    _selectedDay != null && _isSameDay(day, _selectedDay!);
                final isWeekend = day.weekday == DateTime.saturday ||
                    day.weekday == DateTime.sunday;
                final isPast = day
                    .isBefore(DateTime.now().subtract(const Duration(days: 1)));
                final isDisabled = isWeekend || isPast;

                return InkWell(
                  onTap: isDisabled
                      ? null
                      : () {
                          setState(() {
                            _selectedDay = day;
                            _selectedTime = null;
                          });
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                              ? theme.colorScheme.secondary
                                  .withValues(alpha: 0.3)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: ResponsiveText.bodySmall(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDisabled
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3)
                                  : isWeekend
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget des créneaux horaires
  Widget _buildTimeSlots(
      ThemeData theme, GoogleCalendarService? calendarService) {
    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre
          ResponsiveText.bodyMedium(
            _selectedDay == null
                ? 'Créneaux disponibles'
                : 'Créneaux pour le ${_formatDate(_selectedDay!)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Liste des créneaux
          if (_selectedDay == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                    ResponsiveText.bodySmall(
                      'Sélectionnez une date\ndans le calendrier',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _availableTimeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _availableTimeSlots[index];
                  final isSelected = _selectedTime == slot;

                  return ResponsiveBox(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTime = slot;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: ResponsiveBox(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              const ResponsiveBox(
                                  paddingSize: ResponsiveSpacing.s),
                              ResponsiveText.bodyMedium(
                                slot.format(context),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Bouton de confirmation
          ResponsiveBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (_selectedDay != null && _selectedTime != null)
                  ? () => _confirmBooking(calendarService)
                  : null,
              icon: const Icon(Icons.check),
              label: const ResponsiveText.bodyMedium(
                'Confirmer le rendez-vous',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmer la réservation
  Future<void> _confirmBooking(GoogleCalendarService? calendarService) async {
    if (_selectedDay == null ||
        _selectedTime == null ||
        calendarService == null) {
      return;
    }

    try {
      // Créer la date complète
      final start = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final end = start.add(const Duration(hours: 1));

      developer.log('📅 Création RDV: ${start.toIso8601String()}');

      // Créer l'événement dans Google Calendar
      await calendarService.createEvent(
        summary: 'Rendez-vous Portfolio - Discussion projet',
        description:
            'Café virtuel pour discuter de votre projet avec Emryck Doré',
        start: start,
        end: end,
      );

      developer.log('✅ Événement créé avec succès');

      if (mounted) {
        // Afficher le succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                Expanded(
                  child: ResponsiveText.bodyMedium(
                    'Rendez-vous confirmé le ${_formatDate(_selectedDay!)} à ${_selectedTime!.format(context)} !',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Fermer le dialog
        context.pop();
      }
    } catch (e) {
      developer.log('❌ Erreur création RDV: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                Expanded(
                  child: ResponsiveText.bodySmall('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helpers
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
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
