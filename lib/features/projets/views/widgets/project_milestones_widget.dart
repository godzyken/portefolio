import 'package:flutter/material.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

/// Item représentant un jalon ou sprint
class ProjectSprintItem {
  final int step;
  final String title;
  final String description;
  final String status; // 'completed', 'in_progress', 'planned'
  final int completion; // 0 à 100

  const ProjectSprintItem({
    required this.step,
    required this.title,
    required this.description,
    required this.status,
    required this.completion,
  });

  factory ProjectSprintItem.fromJson(Map<String, dynamic> json) {
    return ProjectSprintItem(
      step: json['step'] as int? ?? 1,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'planned',
      completion: (json['completion'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Widget interactif pour la barre de progression des jalons & sprints
class ProjectMilestonesProgressBar extends StatefulWidget {
  final List<ProjectSprintItem> sprints;
  final ResponsiveInfo info;
  final String title;
  final String subtitle;

  const ProjectMilestonesProgressBar({
    super.key,
    required this.sprints,
    required this.info,
    this.title = '🚀 Jalons & Sprints Accomplis',
    this.subtitle =
        'Évolution progressive de l’application vers un écosystème numérique métier complexe.',
  });

  @override
  State<ProjectMilestonesProgressBar> createState() =>
      _ProjectMilestonesProgressBarState();
}

class _ProjectMilestonesProgressBarState
    extends State<ProjectMilestonesProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int? _selectedSprintStep;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  double get _overallProgress {
    if (widget.sprints.isEmpty) return 0.0;
    final total = widget.sprints.fold<int>(0, (sum, s) => sum + s.completion);
    return (total / (widget.sprints.length * 100)).clamp(0.0, 1.0);
  }

  int get _completedCount {
    return widget.sprints.where((s) => s.status == 'completed').length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sprints.isEmpty) return const SizedBox.shrink();

    final isMobile = widget.info.isMobile;
    final progressVal = _overallProgress;
    final progressPct = (progressVal * 100).toInt();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorHelpers.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: ColorHelpers.cyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.flag_circle_rounded,
                  color: ColorHelpers.cyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText.titleMedium(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText.bodySmall(
                      widget.subtitle,
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barre de progression globale
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final animatedValue = progressVal * _progressController.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.insights,
                              color: Colors.cyanAccent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Progression globale : $progressPct%',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '$_completedCount/${widget.sprints.length} Jalons Validés',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: animatedValue,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.cyanAccent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Fil conducteur : Évolution vers une app plus complexe
          _buildEvolutionIndicator(),
          const SizedBox(height: 28),

          // Liste verticale/grille des sprints & jalons
          const ResponsiveText.titleSmall(
            '📌 Détails des Sprints & Accomplissements',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.sprints.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sprint = widget.sprints[index];
              final isSelected = _selectedSprintStep == sprint.step;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSprintStep = isSelected ? null : sprint.step;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorHelpers.cyan.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? ColorHelpers.cyan
                          : _getStatusColor(sprint.status)
                              .withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Numéro de jalon
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _getStatusColor(sprint.status)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getStatusColor(sprint.status),
                              ),
                            ),
                            child: Text(
                              '${sprint.step}',
                              style: TextStyle(
                                color: _getStatusColor(sprint.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sprint.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sprint.description,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSprintStatusBadge(sprint),
                        ],
                      ),

                      // Barre de completion du sprint individuel (visible si sélectionné)
                      if (isSelected) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Niveau de réalisation du sprint',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${sprint.completion}%',
                              style: TextStyle(
                                color: _getStatusColor(sprint.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sprint.completion / 100.0,
                            minHeight: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(sprint.status),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade900.withValues(alpha: 0.4),
            Colors.purple.shade900.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded,
                  color: Colors.purpleAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Trajectoire : Du Site Applicatif vers l’Écosystème Métier',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildEvolutionStep('1. AMOA & Besoin', true),
                _buildEvolutionArrow(),
                _buildEvolutionStep('2. App Web Flutter', true),
                _buildEvolutionArrow(),
                _buildEvolutionStep('3. CI/CD & Sécurité', true),
                _buildEvolutionArrow(),
                _buildEvolutionStep('4. SEO & Data', true),
                _buildEvolutionArrow(),
                _buildEvolutionStep('5. CRM & Automatisation', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionStep(String label, bool isAchieved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAchieved
            ? Colors.purple.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAchieved
              ? Colors.purpleAccent
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAchieved ? Colors.white : Colors.white38,
          fontSize: 11,
          fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEvolutionArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right_rounded,
        color: Colors.purpleAccent,
        size: 18,
      ),
    );
  }

  Widget _buildSprintStatusBadge(ProjectSprintItem sprint) {
    final color = _getStatusColor(sprint.status);
    final String text;
    final IconData icon;

    switch (sprint.status) {
      case 'completed':
        text = 'Complété';
        icon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
        text = 'En cours';
        icon = Icons.autorenew_rounded;
        break;
      default:
        text = 'Planifié';
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.greenAccent;
      case 'in_progress':
        return Colors.cyanAccent;
      default:
        return Colors.amberAccent;
    }
  }
}
