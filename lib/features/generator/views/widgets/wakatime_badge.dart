import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';

import '../../../projets/providers/projects_extentions_providers.dart';
import '../../data/extention_models.dart';
import '../../services/wakatime_service.dart';

/// Badge WakaTime amélioré avec indicateur de tracking
class WakaTimeBadge extends ConsumerWidget {
  final String projectName;
  final bool showTimeSpent;
  final bool showTrackingIndicator;
  final bool compact;

  const WakaTimeBadge({
    super.key,
    required this.projectName,
    this.showTimeSpent = true,
    this.showTrackingIndicator = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTracked = ref.watch(isProjectTrackedProvider(projectName));
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));

    if (!isTracked && !showTrackingIndicator) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactBadge(context, isTracked, timeSpentAsync);
    }

    return ResponsiveBox(
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
            ResponsiveBox(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isTracked ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: isTracked
                    ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),

          const SizedBox(width: 4),

          // --- Affichage du temps passé selon l'état asynchrone ---
          if (showTimeSpent)
            timeSpentAsync.when(
              data: (duration) {
                if (duration == null) {
                  return ResponsiveText.bodySmall(
                    isTracked ? 'Tracké' : 'Non tracké',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isTracked ? Colors.blue : Colors.grey,
                    ),
                  );
                }
                return ResponsiveText.bodySmall(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isTracked ? Colors.blue.shade700 : Colors.grey,
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (err, _) => const ResponsiveText.bodySmall(
                'Erreur',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            )
          else
            ResponsiveText.bodySmall(
              isTracked ? 'Tracké' : 'Non tracké',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isTracked ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(
    BuildContext context,
    bool isTracked,
    AsyncValue<Duration?> timeSpentAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTracked
            ? Colors.blue.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: isTracked ? Colors.blue.shade600 : Colors.grey,
          ),
          const SizedBox(width: 4),
          timeSpentAsync.when(
            data: (duration) => Text(
              duration != null ? _formatDuration(duration) : '0h',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isTracked ? Colors.blue.shade700 : Colors.grey,
              ),
            ),
            loading: () => const SizedBox(
              height: 10,
              width: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            error: (_, __) => Text(
              'N/A',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
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
      fit: BoxFit.contain,
      placeholderBuilder: (_) => SizedBox(
        height: height,
        width: height * 3,
        child: Center(
          child: SizedBox(
            height: height * 0.6,
            width: height * 0.6,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorBuilder: (context, url, error) => _buildFallbackBadge(),
    );
  }

  Widget _buildFallbackBadge() {
    return ResponsiveBox(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: height * 0.7, color: Colors.grey),
          const SizedBox(width: 4),
          ResponsiveText.bodyMedium(
            'WakaTime',
            style: TextStyle(
              fontSize: height * 0.6,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget combiné avec tooltip et stats détaillées
class WakaTimeDetailedBadge extends ConsumerWidget {
  final String projectName;
  final bool showSvgBadge;

  const WakaTimeDetailedBadge({
    super.key,
    required this.projectName,
    this.showSvgBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTracked = ref.watch(isProjectTrackedProvider(projectName));
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));
    final wakaProject = ref.watch(wakaTimeProjectProvider(projectName));

    if (!isTracked) {
      return const SizedBox.shrink();
    }

    // Si le projet a un badge officiel et qu'on veut l'afficher
    if (showSvgBadge && wakaProject?.badge != null) {
      return Tooltip(
        message: _buildTooltipMessage(isTracked, timeSpentAsync, statsAsync),
        child: WakaTimeSvgBadge(projectName: projectName),
      );
    }

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
          loading: () => Container(
            key: ValueKey('badge_${projectName}_loading'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1.5),
            ),
            child: const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, _) => Container(
            key: ValueKey('badge_${projectName}_error'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'WakaTime indisponible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
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

    return buffer.toString().trim();
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

class SafeWakaTimeBadge extends ConsumerWidget {
  final String projectName;
  final bool showTimeSpent;
  final bool showTrackingIndicator;
  final bool compact;

  const SafeWakaTimeBadge({
    super.key,
    required this.projectName,
    this.showTimeSpent = true,
    this.showTrackingIndicator = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utiliser le provider asynchrone
    final trackingStatus =
        ref.watch(projectTrackingStatusProvider(projectName));

    return trackingStatus.when(
      data: (isTracked) {
        if (!isTracked && !showTrackingIndicator) {
          return const SizedBox.shrink();
        }

        return WakaTimeBadge(
          projectName: projectName,
          showTimeSpent: showTimeSpent,
          showTrackingIndicator: showTrackingIndicator,
          compact: compact,
        );
      },
      loading: () => _buildLoadingBadge(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingBadge() {
    if (!showTrackingIndicator) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: compact ? 12 : 16,
            height: compact ? 12 : 16,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            'WakaTime...',
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget détaillé sécurisé
class SafeWakaTimeDetailedBadge extends ConsumerWidget {
  final String projectName;
  final bool showSvgBadge;

  const SafeWakaTimeDetailedBadge({
    super.key,
    required this.projectName,
    this.showSvgBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingStatus =
        ref.watch(projectTrackingStatusProvider(projectName));

    return trackingStatus.when(
      data: (isTracked) {
        if (!isTracked) return const SizedBox.shrink();

        return WakaTimeDetailedBadge(
          projectName: projectName,
          showSvgBadge: showSvgBadge,
        );
      },
      loading: () => _buildLoadingIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Chargement WakaTime...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Wrapper pour afficher conditionnellement le contenu WakaTime
class WakaTimeConditionalWidget extends ConsumerWidget {
  final String projectName;
  final Widget Function(bool isTracked) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const WakaTimeConditionalWidget({
    super.key,
    required this.projectName,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingStatus =
        ref.watch(projectTrackingStatusProvider(projectName));

    return trackingStatus.when(
      data: (isTracked) => builder(isTracked),
      loading: () => loadingWidget ?? const SizedBox.shrink(),
      error: (_, __) => errorWidget ?? const SizedBox.shrink(),
    );
  }
}
