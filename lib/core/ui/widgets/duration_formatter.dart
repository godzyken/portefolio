class DurationFormatter {
  /// Formate une durée en format "Xh Ymin"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Formate des secondes en format "Xh Ymin"
  static String formatSeconds(double totalSeconds) {
    final duration = Duration(seconds: totalSeconds.toInt());
    return formatDuration(duration);
  }

  /// Formate en format court (pour badges)
  static String formatShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' ${minutes}m' : ''}';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Formate en format long
  static String formatLong(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    final parts = <String>[];

    if (days > 0) parts.add('$days jour${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours heure${hours > 1 ? 's' : ''}');
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }

    return parts.join(', ');
  }

  /// Formate en format digital (HH:MM:SS)
  static String formatDigital(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Formate des secondes en format digital
  static String formatSecondsDigital(double totalSeconds) {
    final duration = Duration(seconds: totalSeconds.toInt());
    return formatDigital(duration);
  }
}
