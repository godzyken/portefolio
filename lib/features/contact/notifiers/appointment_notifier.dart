import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/state/appointment_state.dart';
import '../model/state/time_slot_state.dart';
import '../providers/calendar_provider.dart';
import '../providers/emailjs_provider.dart';

class AppointmentNotifier extends Notifier<AppointmentState> {
  @override
  AppointmentState build() {
    return const AppointmentState();
  }

  /// Met à jour le nom, l'email et le message du contact.
  void setContactInfo(String name, String email, String message) {
    state = state.copyWith(
      name: name,
      email: email,
      message: message,
    );
  }

  void setSelectedDate(DateTime? day) {
    state = state.copyWith(selectedDate: day);
  }

  /// Définit le type de rendez-vous (virtuel ou physique).
  void setAppointmentType(AppointmentType type) {
    state = state.copyWith(
      type: type,
      // Réinitialise la location physique si on passe en virtuel
      physicalLocation:
          type == AppointmentType.virtual ? null : state.physicalLocation,
    );
  }

  void setPhysicalLocation(String? value) {
    state = state.copyWith(physicalLocation: value);
  }

  /// Définit le créneau horaire sélectionné.
  void setSelectedTime(TimeSlot? slot) {
    state = state.copyWith(selectedTime: slot);
  }

  Future<bool> confirmAppointment() async {
    final calendarService = ref.read(calendarAvailabilityServiceProvider);
    final emailService = ref.read(emailJsProvider);

    if (!state.canConfirm) {
      state = state.copyWith(
        status: AppointmentStatus.error,
        errorMessage:
            'Veuillez remplir tous les champs obligatoires (date, heure, nom, email, message, et lieu physique si applicable).',
      );
      return false;
    }

    state =
        state.copyWith(status: AppointmentStatus.loading, errorMessage: null);

    try {
      final selectedDate = state.selectedDate!;
      final selectedTime = state.selectedTime!;

      // 1. Construire les objets DateTime de début et de fin
      final eventStart = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // La durée est implicitement d'une heure, comme défini dans getAvailableTimeSlots
      final eventEnd = eventStart.add(const Duration(hours: 1));

      // 2. Créer l'événement avec vérification de disponibilité
      final createdEvent = await calendarService?.createEventIfAvailable(
        summary: 'RDV - ${state.name} (${state.type.name})',
        start: eventStart,
        end: eventEnd,
        description:
            'Type: ${state.type.name}\nLieu: ${state.physicalLocation ?? 'Virtuel'}\nMessage: ${state.message}\nEmail: ${state.email}',
      );

      if (createdEvent == null) {
        // Si le service renvoie null au lieu de lever une exception
        throw Exception("La création de l'événement a échoué.");
      }

      // 3. Préparer les données pour l'email (format lisible)
      final appointmentDetails = {
        'date':
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        'time':
            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} - ${(selectedTime.hour + 1).toString()}:${selectedTime.minute.toString().padLeft(2, '0')}',
        'type': state.type.name,
        'location': state.physicalLocation ?? 'Virtuel',
        'attendee': state.name,
        'email': state.email,
        'message': state.message,
      };

      // 4. Envoyer un email de confirmation
      await emailService.sendAppointmentConfirmation(
          appointmentDetails: appointmentDetails);

      // Succès
      state = state.copyWith(status: AppointmentStatus.success);

      // Réinitialiser l'état pour une nouvelle réservation
      state = AppointmentState(name: state.name, email: state.email);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AppointmentStatus.error,
        errorMessage:
            'Une erreur est survenue : ${e.toString().contains("plus disponible") ? "Ce créneau n'est malheureusement plus disponible." : e.toString()}',
      );
      return false;
    }
  }
}
