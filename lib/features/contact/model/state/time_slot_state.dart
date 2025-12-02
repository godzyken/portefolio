class TimeSlot {
  final int hour;
  final int minute;
  final bool isAvailable;

  const TimeSlot({
    required this.hour,
    required this.minute,
    this.isAvailable = true,
  });

  TimeSlot copyWith({bool? isAvailable}) {
    return TimeSlot(
      hour: hour,
      minute: minute,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
