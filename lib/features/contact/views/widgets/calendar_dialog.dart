import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../model/state/appointment_state.dart';
import '../../providers/calendar_provider.dart';

class CalendarDialog extends ConsumerStatefulWidget {
  const CalendarDialog({super.key});

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  DateTime _focusedMonth = DateTime.now();
  bool _isLoadingSlots = false;
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final appointmentState = ref.watch(appointmentProvider);

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
            _buildHeader(theme),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 400, child: _buildCalendar(theme)),
                          Divider(
                            height: 1,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.1),
                          ),
                          SizedBox(
                            height: 500,
                            child: _buildRightPanel(theme, appointmentState),
                          ),
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildCalendar(theme)),
                      VerticalDivider(
                        width: 1,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildRightPanel(theme, appointmentState),
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

  Widget _buildHeader(ThemeData theme) {
    return ResponsiveBox(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
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
                  'Sélectionnez une date, un créneau et le type',
                  style: TextStyle(color: Colors.white70),
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

  Widget _buildCalendar(ThemeData theme) {
    final appointmentState = ref.watch(appointmentProvider);
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                    '1. Choisissez une date disponible',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
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
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayNumber = index - startingWeekday + 2;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final day = DateTime(
                    _focusedMonth.year, _focusedMonth.month, dayNumber);
                final isToday = _isSameDay(day, DateTime.now());
                final isSelected = appointmentState.selectedDate != null &&
                    _isSameDay(day, appointmentState.selectedDate!);
                final isWeekend = day.weekday == DateTime.saturday ||
                    day.weekday == DateTime.sunday;
                final isPast = day
                    .isBefore(DateTime.now().subtract(const Duration(days: 1)));
                final isDisabled = isWeekend || isPast;

                return InkWell(
                  onTap: isDisabled
                      ? null
                      : () async {
                          ref
                              .read(appointmentProvider.notifier)
                              .setSelectedDate(day);
                          setState(() => _isLoadingSlots = true);
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          if (mounted) {
                            setState(() => _isLoadingSlots = false);
                          }
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

  Widget _buildRightPanel(ThemeData theme, AppointmentState state) {
    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sélection du type
          _buildTypeSelector(theme, state),
          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Champ lieu si physique
          if (state.type == AppointmentType.physical)
            _buildLocationField(theme),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Créneaux horaires
          Expanded(child: _buildTimeSlots(theme, state)),

          const ResponsiveBox(paddingSize: ResponsiveSpacing.m),

          // Bouton de confirmation
          _buildConfirmButton(theme, state),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme, AppointmentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText.bodyMedium(
          '2. Type de rendez-vous',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
        Row(
          children: [
            Expanded(
              child: _buildTypeChip(
                theme,
                'Virtuel',
                Icons.videocam,
                AppointmentType.virtual,
                state.type == AppointmentType.virtual,
              ),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
            Expanded(
              child: _buildTypeChip(
                theme,
                'Physique',
                Icons.place,
                AppointmentType.physical,
                state.type == AppointmentType.physical,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(ThemeData theme, String label, IconData icon,
      AppointmentType type, bool isSelected) {
    return InkWell(
      onTap: () =>
          ref.read(appointmentProvider.notifier).setAppointmentType(type),
      borderRadius: BorderRadius.circular(12),
      child: ResponsiveBox(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
            ResponsiveText.bodySmall(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveText.bodySmall(
          'Lieu du rendez-vous (< 200 km)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Ville ou adresse...',
            prefixIcon:
                Icon(Icons.location_on, color: theme.colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) =>
              ref.read(appointmentProvider.notifier).setPhysicalLocation(value),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(ThemeData theme, AppointmentState appointmentState) {
    if (appointmentState.selectedDate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            const ResponsiveText.bodySmall(
              'Sélectionnez d\'abord\nune date',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final availableSlotsAsync =
        ref.watch(availableTimeSlotsProvider(appointmentState.selectedDate!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText.bodyMedium(
          '3. Choisissez un créneau',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.s),
        Expanded(
          child: availableSlotsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: ResponsiveText.bodySmall(
                'Erreur de chargement',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            data: (availableSlots) {
              if (availableSlots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 64,
                          color:
                              theme.colorScheme.error.withValues(alpha: 0.5)),
                      const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
                      const ResponsiveText.bodySmall(
                        'Aucun créneau disponible',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = availableSlots[index];
                  final isSelected = appointmentState.selectedTime == slot;

                  return ResponsiveBox(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => ref
                          .read(appointmentProvider.notifier)
                          .setSelectedTime(slot),
                      borderRadius: BorderRadius.circular(12),
                      child: ResponsiveBox(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
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
                              slot.toString(),
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
                              Icon(Icons.check_circle,
                                  color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(ThemeData theme, AppointmentState state) {
    return ResponsiveBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: state.canConfirm ? () => _confirmAppointment() : null,
        icon: state.status == AppointmentStatus.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check),
        label: ResponsiveText.bodyMedium(
          state.status == AppointmentStatus.loading
              ? 'Confirmation...'
              : 'Confirmer le rendez-vous',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Future<void> _confirmAppointment() async {
    final success =
        await ref.read(appointmentProvider.notifier).confirmAppointment();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              Expanded(
                child: ResponsiveText.bodyMedium(
                  'Rendez-vous confirmé ! Email envoyé.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(appointmentProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              Expanded(
                child:
                    ResponsiveText.bodySmall('Erreur: ${error ?? "Inconnue"}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
}
