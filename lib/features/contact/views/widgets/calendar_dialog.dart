import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../generator/views/widgets/animations/diagnostic_progress_bar.dart';
import '../../model/state/appointment_state.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/emailjs_provider.dart';

class CalendarDialog extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialMessage;

  const CalendarDialog({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialMessage,
  });

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  int _currentStep = 0;
  final int _totalSteps = 5;
  DateTime _focusedMonth = DateTime.now();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final appointmentNotifier = ref.read(appointmentProvider.notifier);

    // Initialisation des contrôleurs
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _messageController.text = widget.initialMessage ?? '';

    // Initialisation du provider avec les valeurs initiales
    if (widget.initialName != null ||
        widget.initialEmail != null ||
        widget.initialMessage != null) {
      appointmentNotifier.setContactInfo(
        _nameController.text,
        _emailController.text,
        _messageController.text,
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(responsiveInfoProvider);
    final appointmentState = ref.watch(appointmentProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ResponsiveBox(
        width: info.size.width > 720 ? 720 : info.size.width * 0.95,
        height: info.size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E), // Couleur sombre style diagnostic
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildProgressBar(theme),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentStep(theme, appointmentState),
                ),
              ),
              _buildFooter(theme, appointmentState),
            ],
          ),
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
                  'Parcours simple et rapide',
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

  Widget _buildProgressBar(ThemeData theme) {
    return DiagnosticProgressBar(
      current: _currentStep + 1,
      total: _totalSteps,
      color: theme.colorScheme.primary,
    );
  }

  Widget _buildCurrentStep(ThemeData theme, AppointmentState state) {
    switch (_currentStep) {
      case 0:
        return _buildCalendarStep(theme, state);
      case 1:
        return _buildTimeStep(theme, state);
      case 2:
        return _buildTypeStep(theme, state);
      case 3:
        return _buildInfoStep(theme, state);
      case 4:
        return _buildReviewStep(theme, state);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEPS ---

  Widget _buildCalendarStep(ThemeData theme, AppointmentState state) {
    return _StepContainer(
      key: const ValueKey('step0'),
      title: 'Choisissez une date',
      child: _buildCalendar(theme),
    );
  }

  Widget _buildTimeStep(ThemeData theme, AppointmentState state) {
    return _StepContainer(
      key: const ValueKey('step1'),
      title: 'Choisissez un créneau',
      child: _buildTimeSlots(theme, state),
    );
  }

  Widget _buildTypeStep(ThemeData theme, AppointmentState state) {
    return _StepContainer(
      key: const ValueKey('step2'),
      title: 'Type de rendez-vous',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTypeSelector(theme, state),
            if (state.type == AppointmentType.physical) ...[
              const ResponsiveBox(paddingSize: ResponsiveSpacing.l),
              _buildLocationField(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(ThemeData theme, AppointmentState state) {
    return _StepContainer(
      key: const ValueKey('step3'),
      title: 'Vos informations',
      child: SingleChildScrollView(
        child: Column(
          children: [
            NameFormField(
              controller: _nameController,
              onChanged: (val) => ref
                  .read(appointmentProvider.notifier)
                  .setContactInfo(val, _emailController.text, _messageController.text),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            EmailFormField(
              controller: _emailController,
              onChanged: (val) => ref
                  .read(appointmentProvider.notifier)
                  .setContactInfo(_nameController.text, val, _messageController.text),
            ),
            const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
            MessageFormField(
              controller: _messageController,
              onChanged: (val) => ref
                  .read(appointmentProvider.notifier)
                  .setContactInfo(_nameController.text, _emailController.text, val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(ThemeData theme, AppointmentState state) {
    return _StepContainer(
      key: const ValueKey('step4'),
      title: 'Récapitulatif',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildReviewItem(
              theme,
              Icons.event,
              'Date',
              state.selectedDate != null
                  ? _formatDate(state.selectedDate!)
                  : 'Non sélectionnée',
            ),
            _buildReviewItem(
              theme,
              Icons.access_time,
              'Heure',
              state.selectedTime?.toString() ?? 'Non sélectionnée',
            ),
            _buildReviewItem(
              theme,
              state.type == AppointmentType.virtual ? Icons.videocam : Icons.place,
              'Type',
              state.type == AppointmentType.virtual
                  ? 'Virtuel (Visio)'
                  : 'Physique (${state.physicalLocation ?? "Lieu non précisé"})',
            ),
            const Divider(color: Colors.white24, height: 32),
            _buildReviewItem(theme, Icons.person, 'Nom', state.name),
            _buildReviewItem(theme, Icons.email, 'Email', state.email),
            _buildReviewItem(theme, Icons.chat, 'Message', state.message),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText.bodySmall(label, style: const TextStyle(color: Colors.white70)),
                ResponsiveText.bodyMedium(value,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER ---

  Widget _buildFooter(ThemeData theme, AppointmentState state) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _canGoNext(state)
                  ? (isLastStep ? () => _confirmAppointment() : _nextStep)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: state.status == AppointmentStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isLastStep ? 'Confirmer' : 'Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoNext(AppointmentState state) {
    switch (_currentStep) {
      case 0:
        return state.selectedDate != null;
      case 1:
        return state.selectedTime != null;
      case 2:
        return state.type == AppointmentType.virtual ||
            (state.type == AppointmentType.physical &&
                state.physicalLocation != null &&
                state.physicalLocation!.isNotEmpty);
      case 3:
        return state.name.isNotEmpty &&
            state.email.isNotEmpty &&
            state.message.isNotEmpty &&
            RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(state.email);
      case 4:
        return state.canConfirm && state.status != AppointmentStatus.loading;
      default:
        return false;
    }
  }

  // --- REUSED UI COMPONENTS ---

  Widget _buildCalendar(ThemeData theme) {
    final appointmentState = ref.watch(appointmentProvider);
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
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
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () {
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
            return Expanded(
              child: Center(
                child: ResponsiveText.bodySmall(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white54),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - startingWeekday + 2;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isToday = _isSameDay(day, DateTime.now());
              final isSelected = appointmentState.selectedDate != null &&
                  _isSameDay(day, appointmentState.selectedDate!);
              final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
              final isPast = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
              final isDisabled = isWeekend || isPast;

              return InkWell(
                onTap: isDisabled
                    ? null
                    : () {
                        ref.read(appointmentProvider.notifier).setSelectedDate(day);
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isToday
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: ResponsiveText.bodySmall(
                      '$dayNumber',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isDisabled
                                ? Colors.white24
                                : isWeekend
                                    ? theme.colorScheme.error
                                    : Colors.white,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots(ThemeData theme, AppointmentState appointmentState) {
    if (appointmentState.selectedDate == null) {
      return const Center(child: Text('Erreur: Pas de date choisie', style: TextStyle(color: Colors.white70)));
    }

    final availableSlotsAsync = ref.watch(availableTimeSlotsProvider(appointmentState.selectedDate!));

    return availableSlotsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text('Erreur de chargement des créneaux',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(err.toString(),
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
      data: (availableSlots) {
        if (availableSlots.isEmpty) {
          return const Center(
            child: Text('Aucun créneau disponible pour cette date',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          itemCount: availableSlots.length,
          itemBuilder: (context, index) {
            final slot = availableSlots[index];
            final isSelected = appointmentState.selectedTime == slot;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => ref.read(appointmentProvider.notifier).setSelectedTime(slot),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : Colors.white10,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: isSelected ? theme.colorScheme.primary : Colors.white54),
                      const SizedBox(width: 16),
                      ResponsiveText.bodyMedium(
                        slot.toString(),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeSelector(ThemeData theme, AppointmentState state) {
    return Row(
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
        const SizedBox(width: 16),
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
    );
  }

  Widget _buildTypeChip(ThemeData theme, String label, IconData icon, AppointmentType type, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(appointmentProvider.notifier).setAppointmentType(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.white54, size: 32),
            const SizedBox(height: 12),
            ResponsiveText.bodySmall(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(ThemeData theme) {
    return TextFormField(
      controller: _locationController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Ville ou adresse...',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) => ref.read(appointmentProvider.notifier).setPhysicalLocation(value),
    );
  }

  Future<void> _confirmAppointment() async {
    final appointmentNotifier = ref.read(appointmentProvider.notifier);

    // Sync from controllers
    appointmentNotifier.setContactInfo(
      _nameController.text,
      _emailController.text,
      _messageController.text,
    );
    appointmentNotifier.setPhysicalLocation(_locationController.text);

    final calendarService = ref.read(calendarAvailabilityServiceProvider);
    final emailService = ref.read(emailJsProvider);

    final success = await appointmentNotifier.confirmAppointment(calendarService, emailService);

    if (!mounted) return;

    if (success) {
      _showSnackBar('Rendez-vous confirmé ! Email envoyé.', Colors.green);
      context.pop();
    } else {
      final error = ref.read(appointmentProvider).errorMessage;
      _showSnackBar('Erreur: ${error ?? "Inconnue"}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(DateTime date) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date)}';
  }
}

class _StepContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _StepContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText.titleLarge(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}
