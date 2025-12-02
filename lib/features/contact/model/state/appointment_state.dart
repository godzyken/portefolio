import 'package:portefolio/features/contact/model/state/time_slot_state.dart';

enum AppointmentType { virtual, physical }

enum AppointmentStatus { idle, loading, success, error }

class AppointmentState {
  final DateTime? selectedDate;
  final TimeSlot? selectedTime;
  final AppointmentType type;
  final String? physicalLocation;
  final AppointmentStatus status;
  final String? errorMessage;
  final String name;
  final String email;
  final String message;

  const AppointmentState({
    this.selectedDate,
    this.selectedTime,
    this.type = AppointmentType.virtual,
    this.physicalLocation,
    this.status = AppointmentStatus.idle,
    this.errorMessage,
    this.name = '',
    this.email = '',
    this.message = '',
  });

  AppointmentState copyWith({
    DateTime? selectedDate,
    TimeSlot? selectedTime,
    AppointmentType? type,
    String? physicalLocation,
    AppointmentStatus? status,
    String? errorMessage,
    String? name,
    String? email,
    String? message,
  }) {
    return AppointmentState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      type: type ?? this.type,
      physicalLocation: physicalLocation ?? this.physicalLocation,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
    );
  }

  bool get canConfirm =>
      selectedDate != null &&
      selectedTime != null &&
      name.isNotEmpty &&
      email.isNotEmpty &&
      message.isNotEmpty &&
      (type == AppointmentType.virtual ||
          (type == AppointmentType.physical &&
              physicalLocation != null &&
              physicalLocation!.isNotEmpty));
}
