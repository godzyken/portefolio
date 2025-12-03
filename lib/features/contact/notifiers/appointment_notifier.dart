import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/state/appointment_state.dart';
import '../model/state/time_slot_state.dart';
import '../services/emailjs_service.dart';
import '../services/google_calendar_service.dart';

class AppointmentNotifier extends Notifier<AppointmentState> {
  @override
  AppointmentState build() {
    return const AppointmentState();
  }

  void setContactInfo(String name, String email, String message) {
    state = state.copyWith(
      name: name,
      email: email,
      message: message,
    );
  }

  void setSelectedDate(DateTime? date) {
    state = state.copyWith(
      selectedDate: date,
      selectedTime: null, // Reset time when date changes
    );
  }

  void setSelectedTime(TimeSlot? time) {
    state = state.copyWith(selectedTime: time);
  }

  void setAppointmentType(AppointmentType type) {
    state = state.copyWith(type: type);
  }

  void setPhysicalLocation(String? location) {
    state = state.copyWith(physicalLocation: location);
  }

  Future<bool> confirmAppointment(
    CalendarAvailabilityService calendarService,
    EmailJsService emailService,
  ) async {
    if (!state.canConfirm) {
      state = state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: 'Veuillez remplir tous les champs requis',
      );
      return false;
    }

    state = state.copyWith(status: AppointmentStatus.loading);

    try {
      // Créer la date complète
      final start = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        state.selectedTime!.hour,
        state.selectedTime!.minute,
      );
      final end = start.add(const Duration(hours: 1));

      // Construire le résumé et la description selon le type
      final summary = state.type == AppointmentType.virtual
          ? 'Rendez-vous virtuel - ${state.name}'
          : 'Rendez-vous physique - ${state.name}';

      final description = _buildDescription();

      developer.log('📅 Création RDV: ${start.toIso8601String()}');
      developer.log('Type: ${state.type}');
      developer.log('Description: $description');

      // Créer l'événement dans Google Calendar
      await calendarService.createEventIfAvailable(
        summary: summary,
        description: description,
        start: start,
        end: end,
      );

      developer.log('✅ Événement créé avec succès');

      // Envoyer l'email de confirmation
      await _sendConfirmationEmail(emailService, start);

      state = state.copyWith(status: AppointmentStatus.success);
      return true;
    } catch (e, st) {
      developer.log('❌ Erreur création RDV: $e', stackTrace: st);
      state = state.copyWith(
        status: AppointmentStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  String _buildDescription() {
    final buffer = StringBuffer();

    buffer.writeln('DEMANDE DE RENDEZ-VOUS');
    buffer.writeln('=' * 50);
    buffer.writeln();

    buffer.writeln('👤 Contact:');
    buffer.writeln('Nom: ${state.name}');
    buffer.writeln('Email: ${state.email}');
    buffer.writeln();

    buffer.writeln('📍 Type de rendez-vous:');
    if (state.type == AppointmentType.virtual) {
      buffer.writeln('Rendez-vous VIRTUEL (Teams/Visio)');
    } else {
      buffer.writeln('Rendez-vous PHYSIQUE');
      buffer.writeln('Lieu: ${state.physicalLocation}');
    }
    buffer.writeln();

    buffer.writeln('💬 Message:');
    buffer.writeln(state.message);
    buffer.writeln();

    buffer.writeln('⏰ Créé via le Portfolio');

    return buffer.toString();
  }

  Future<void> _sendConfirmationEmail(
    EmailJsService emailService,
    DateTime appointmentStart,
  ) async {
    final typeText = state.type == AppointmentType.virtual
        ? 'Rendez-vous virtuel (Teams/Visio)'
        : 'Rendez-vous physique à ${state.physicalLocation}';

    final emailMessage = '''
Demande de rendez-vous confirmée !

Date: ${_formatDate(appointmentStart)}
Heure: ${_formatTime(appointmentStart)}
Type: $typeText

Message:
${state.message}

Contact:
Nom: ${state.name}
Email: ${state.email}
''';

    await emailService.sendEmail(
      name: state.name,
      email: state.email,
      message: emailMessage,
    );

    developer.log('✅ Email de confirmation envoyé');
  }

  String _formatDate(DateTime date) {
    const months = [
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void reset() {
    state = const AppointmentState();
  }
}
