import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../projets/providers/projects_extentions_providers.dart';
import '../../services/wakatime_service.dart';

/// Badge WakaTime amélioré avec indicateur de tracking
class WakaTimeBadge extends ConsumerWidget {
  final String projectName;
  final bool showTimeSpent;
  final bool showTrackingIndicator;

  const WakaTimeBadge({
    super.key,
    required this.projectName,
    this.showTimeSpent = true,
    this.showTrackingIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTracked = ref.watch(isProjectTrackedProvider(projectName));
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));

    if (!isTracked && !showTrackingIndicator) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTracked
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTracked ? Colors.blue : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: isTracked ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 4),

          if (showTrackingIndicator)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isTracked ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),

          const SizedBox(width: 4),

          // --- Affichage du temps passé selon l'état asynchrone ---
          if (showTimeSpent)
            timeSpentAsync.when(
              data: (duration) {
                if (duration == null) {
                  return Text(
                    isTracked ? 'Tracké' : 'Non tracké',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isTracked ? Colors.blue : Colors.grey,
                    ),
                  );
                }
                return Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isTracked ? Colors.blue : Colors.grey,
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              error: (err, _) => const Text(
                'Erreur',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            )
          else
            Text(
              isTracked ? 'Tracké' : 'Non tracké',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isTracked ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
}

/// Badge SVG officiel de WakaTime
class WakaTimeSvgBadge extends StatelessWidget {
  final String projectName;
  final double height;

  const WakaTimeSvgBadge({
    super.key,
    required this.projectName,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final badgeUrl = WakaTimeService.getBadgeUrl(projectName);

    return SvgPicture.network(
      badgeUrl,
      height: height,
      placeholderBuilder: (_) => SizedBox(
        height: height,
        width: height,
        child: const CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

/// Widget combiné avec tooltip et stats détaillées
class WakaTimeDetailedBadge extends ConsumerWidget {
  final String projectName;

  const WakaTimeDetailedBadge({
    super.key,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTracked = ref.watch(isProjectTrackedProvider(projectName));
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));

    return Tooltip(
      message: _buildTooltipMessage(isTracked, timeSpentAsync, statsAsync),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: timeSpentAsync.when(
          data: (timeSpent) => WakaTimeBadge(
            key: ValueKey('badge_${projectName}_data'),
            projectName: projectName,
            showTimeSpent: true,
            showTrackingIndicator: true,
          ),
          loading: () => const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (err, _) => Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }

  String _buildTooltipMessage(
    bool isTracked,
    AsyncValue<Duration?> timeSpentAsync,
    AsyncValue<WakaTimeStats?> statsAsync,
  ) {
    if (!isTracked) {
      return '⏱ Ce projet n\'est pas tracké sur WakaTime';
    }

    final buffer = StringBuffer('📊 WakaTime - Derniers 7 jours\n');

    timeSpentAsync.whenData((timeSpent) {
      if (timeSpent != null) {
        buffer.writeln('Temps passé : ${_formatDuration(timeSpent)}');
      } else {
        buffer.writeln('Aucune donnée enregistrée');
      }
    });

    statsAsync.whenData((stats) {
      if (stats != null) {
        final projectStat = stats.projects.firstWhere(
          (p) => p.name.toLowerCase().contains(projectName.toLowerCase()),
          orElse: () => WakaTimeProjectStat(
            name: projectName,
            totalSeconds: 0,
            percent: 0,
            digital: '0:00',
            text: '0 secs',
          ),
        );
        buffer.writeln(
            'Part du temps total : ${projectStat.percent.toStringAsFixed(1)}%');
      }
    });

    return buffer.toString();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
}
