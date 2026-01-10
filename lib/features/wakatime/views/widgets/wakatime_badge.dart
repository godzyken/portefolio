import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../data/wakatime_models_data.dart';
import '../../providers/projects_wakatime_service_provider.dart';
import '../../services/wakatime_service.dart';

/// Définition des variantes d'affichage du badge WakaTime.
enum WakaTimeBadgeVariant {
  /// Badge simple avec indicateur de suivi et temps total.
  simple,

  /// Badge compact affichant uniquement l'icône et le temps (petit format).
  compact,

  /// Badge détaillé avec Tooltip (y compris les statistiques sur 7 jours).
  detailed
}

class _WakaTimeLoadingIndicator extends StatelessWidget {
  final bool compact;
  final bool isError;
  final bool isSvgFallback;
  final double height;

  const _WakaTimeLoadingIndicator({
    super.key,
    this.compact = false,
    this.isError = false,
    this.isSvgFallback = false,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade700 : Colors.grey.shade500;
    final backgroundColor = isError
        ? Colors.red.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.1);

    final size = compact ? 12.0 : 16.0;
    final text =
        isError ? 'Erreur' : (isSvgFallback ? 'WakaTime' : 'WakaTime...');
    final icon = isError ? Icons.warning_amber_rounded : Icons.access_time;

    return Container(
      height: isSvgFallback ? height : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size, color: color),
          SizedBox(width: compact ? 4 : 6),
          if (!isSvgFallback && !isError)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: compact ? 1.5 : 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          if (isSvgFallback || isError)
            ResponsiveText.bodySmall(
              text,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _WakaTimeSvgBadge extends StatelessWidget {
  final String projectName;
  final double height;

  const _WakaTimeSvgBadge({
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
          child: _WakaTimeLoadingIndicator(
              compact: true, height: height * 0.6, isSvgFallback: true),
        ),
      ),
      errorBuilder: (context, url, error) => _WakaTimeLoadingIndicator(
        compact: true,
        height: height,
        isSvgFallback: true,
        isError: true,
      ),
    );
  }
}

class WakaTimeBadgeWidget extends ConsumerWidget {
  final String projectName;
  final WakaTimeBadgeVariant variant;
  final bool showLoadingFallback;
  final bool showTrackingIndicator;
  final double detailedHeight;
  final bool showSvgBadge;

  const WakaTimeBadgeWidget({
    super.key,
    required this.projectName,
    this.variant = WakaTimeBadgeVariant.simple,
    this.showLoadingFallback = true,
    this.showTrackingIndicator = true,
    this.detailedHeight = 20,
    this.showSvgBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Gérer l'état initial du tracking (Safe logic)
    final trackingStatus =
        ref.watch(projectTrackingStatusProvider(projectName));

    return trackingStatus.when(
      data: (isTracked) {
        // 2. Afficher si tracké ou si l'indicateur est requis même si non tracké (simple/compact)
        if (!isTracked &&
            !showTrackingIndicator &&
            variant != WakaTimeBadgeVariant.detailed) {
          return const SizedBox.shrink();
        }

        if (variant == WakaTimeBadgeVariant.detailed) {
          // La variante Detailed n'affiche rien si non tracké
          if (!isTracked) return const SizedBox.shrink();
          return _buildDetailedBadge(ref, isTracked);
        }

        // Pour Simple et Compact
        return _buildSimpleOrCompactBadge(ref, isTracked);
      },
      loading: () {
        // 3. Afficher le chargement si requis
        if (!showLoadingFallback) return const SizedBox.shrink();
        return _WakaTimeLoadingIndicator(
          compact: variant == WakaTimeBadgeVariant.compact,
          height: variant == WakaTimeBadgeVariant.detailed ? 30 : 20,
        );
      },
      error: (_, __) {
        // 4. Afficher l'erreur si requis (même logique que loading)
        if (!showLoadingFallback) return const SizedBox.shrink();
        return _WakaTimeLoadingIndicator(
          isError: true,
          compact: variant == WakaTimeBadgeVariant.compact,
          height: variant == WakaTimeBadgeVariant.detailed ? 30 : 20,
        );
      },
    );
  }

  /// ----------------------------------------------------------------------
  /// LOGIQUE D'AFFICHAGE DES VARIANTES
  /// ----------------------------------------------------------------------

  Widget _buildSimpleOrCompactBadge(WidgetRef ref, bool isTracked) {
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));
    final compact = variant == WakaTimeBadgeVariant.compact;
    final color = isTracked ? Colors.blue : Colors.grey;

    // ----- LOGIQUE COMPACTE -----
    if (compact) {
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
                duration != null
                    ? DurationFormatter.formatDuration(duration)
                    : '0h',
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

    // ----- LOGIQUE SIMPLE -----
    final indicatorColor = isTracked ? Colors.green : Colors.grey;

    return ResponsiveBox(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 4),
          if (showTrackingIndicator) ...[
            ResponsiveBox(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
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
          ],
          timeSpentAsync.when(
            data: (duration) => ResponsiveText.bodySmall(
              duration != null
                  ? DurationFormatter.formatDuration(duration)
                  : isTracked
                      ? 'Tracké'
                      : 'Non tracké',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.shade700,
              ),
            ),
            loading: () => const SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => ResponsiveText.bodySmall(
              'Erreur',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBadge(WidgetRef ref, bool isTracked) {
    final timeSpentAsync = ref.watch(projectTimeSpentProvider(projectName));
    final statsAsync = ref.watch(wakaTimeStatsProvider('last_7_days'));
    final wakaProject = ref.watch(wakaTimeProjectProvider(projectName));

    // Détermine le contenu du Tooltip
    String buildTooltipMessage() {
      final buffer = StringBuffer('📊 WakaTime - Derniers 7 jours\n');

      timeSpentAsync.whenData((timeSpent) {
        if (timeSpent != null) {
          buffer.writeln(
              'Temps passé : ${DurationFormatter.formatShort(timeSpent)}');
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

    // Affichage SVG si demandé et disponible
    if (showSvgBadge && wakaProject?.badge != null) {
      return Tooltip(
        message: buildTooltipMessage(),
        child:
            _WakaTimeSvgBadge(projectName: projectName, height: detailedHeight),
      );
    }

    // Affichage Widget natif
    return Tooltip(
      message: buildTooltipMessage(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: timeSpentAsync.when(
          data: (timeSpent) => _buildSimpleOrCompactBadge(ref, isTracked),
          loading: () => _WakaTimeLoadingIndicator(
            key: ValueKey('badge_${projectName}_loading'),
            compact: false,
            height: detailedHeight * 1.5,
          ),
          error: (err, _) => _WakaTimeLoadingIndicator(
            key: ValueKey('badge_${projectName}_error'),
            isError: true,
            height: detailedHeight * 1.5,
          ),
        ),
      ),
    );
  }
}
