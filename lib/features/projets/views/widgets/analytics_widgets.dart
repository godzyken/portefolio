import 'package:flutter/material.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../data/analytics_models.dart';

class MetricCard extends StatelessWidget {
  final ProjectMetric metric;
  final IconData? icon;

  const MetricCard({
    super.key,
    required this.metric,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Icon(icon, color: _getStatusColor(metric.status), size: 20),
              SourceBadge(status: metric.status, source: metric.source),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatValue(metric.value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (metric.unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  metric.unit,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(1);
    return value.toString();
  }

  Color _getStatusColor(MetricStatus status) {
    switch (status) {
      case MetricStatus.real:
        return Colors.greenAccent;
      case MetricStatus.calculated:
        return Colors.blueAccent;
      case MetricStatus.estimated:
        return Colors.orangeAccent;
      case MetricStatus.unavailable:
        return Colors.grey;
    }
  }
}

class AuditScoreCircle extends StatelessWidget {
  final double score;
  final String label;
  final MetricStatus status;

  const AuditScoreCircle({
    super.key,
    required this.score,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorHelpers.getColorForLevel(score / 100);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                color: color,
              ),
            ),
            Text(
              score.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        SourceBadge(status: status, source: 'Audit Engine', isCompact: true),
      ],
    );
  }
}

class SourceBadge extends StatelessWidget {
  final MetricStatus status;
  final String source;
  final bool isCompact;

  const SourceBadge({
    super.key,
    required this.status,
    required this.source,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          status.name.toUpperCase(),
          style:
              TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status.name.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MetricStatus status) {
    switch (status) {
      case MetricStatus.real:
        return Colors.greenAccent;
      case MetricStatus.calculated:
        return Colors.blueAccent;
      case MetricStatus.estimated:
        return Colors.orangeAccent;
      case MetricStatus.unavailable:
        return Colors.grey;
    }
  }
}

class AuditItemsList extends StatelessWidget {
  final List<AuditItem> items;

  const AuditItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _buildItem(item)).toList(),
    );
  }

  Widget _buildItem(AuditItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            _getAuditIcon(item.status),
            color: _getAuditColor(item.status),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          if (item.message != null)
            Text(
              item.message!,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
    );
  }

  IconData _getAuditIcon(AuditStatus status) {
    switch (status) {
      case AuditStatus.pass:
        return Icons.check_circle;
      case AuditStatus.warning:
        return Icons.warning;
      case AuditStatus.fail:
        return Icons.error;
      case AuditStatus.unavailable:
        return Icons.help_outline;
    }
  }

  Color _getAuditColor(AuditStatus status) {
    switch (status) {
      case AuditStatus.pass:
        return Colors.greenAccent;
      case AuditStatus.warning:
        return Colors.orangeAccent;
      case AuditStatus.fail:
        return Colors.redAccent;
      case AuditStatus.unavailable:
        return Colors.grey;
    }
  }
}
