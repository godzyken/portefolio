import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/device_spec.dart';
import '../../data/project_data.dart';
import '../../providers/projet_providers.dart';
import 'draguable_bubble.dart';

class ProjectGridView extends ConsumerStatefulWidget {
  final List<ProjectInfo> projects;
  final List<ProjectInfo> selected;

  const ProjectGridView({
    super.key,
    required this.projects,
    required this.selected,
  });

  @override
  ConsumerState<ProjectGridView> createState() => _ProjectGridViewState();
}

class _ProjectGridViewState extends ConsumerState<ProjectGridView> {
  Size? _lastScreenSize;
  bool _isInitialized = false;
  String? _expandedProjectId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        final sizeChanged = _lastScreenSize == null ||
            (screenSize.width - _lastScreenSize!.width).abs() > 50 ||
            (screenSize.height - _lastScreenSize!.height).abs() > 50;

        if (sizeChanged || !_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _redistributeBubbles(screenSize);
              setState(() {
                _lastScreenSize = screenSize;
                _isInitialized = true;
              });
            }
          });
        }

        final bubbleSpecs = _calculateBubbleLayout(
          screenSize,
          widget.projects.length,
        );
        final positions = ref.watch(projectPositionsProvider);

        final sortedIndices = List.generate(widget.projects.length, (i) => i)
          ..sort((a, b) {
            final idA = widget.projects[a].id;
            final idB = widget.projects[b].id;
            if (idA == _expandedProjectId) return 1;
            if (idB == _expandedProjectId) return -1;
            return 0;
          });

        return Stack(
          clipBehavior: Clip.none,
          children: sortedIndices
              .map((index) =>
                  _buildBubble(index, screenSize, bubbleSpecs, positions))
              .toList(),
        );
      },
    );
  }

  Widget _buildBubble(
    int index,
    Size screenSize,
    BubbleLayoutSpec spec,
    Map<String, Offset> positions,
  ) {
    final project = widget.projects[index];
    final deviceSpec = _getDeviceSpecForProject(project);
    final bubbleSize = _getBubbleSize(deviceSpec, spec.size);

    return DraggableBubble(
      key: ValueKey(project.id),
      project: project,
      isSelected: widget.selected.any((p) => p.id == project.id) ||
          _expandedProjectId == project.id,
      initialOffset: positions[project.id] ??
          _getInitialPosition(
            index,
            widget.projects.length,
            screenSize,
            spec,
            bubbleSize,
          ),
      onPositionChanged: (offset) {
        final clamped = _clampPosition(offset, screenSize, bubbleSize);
        ref.read(projectPositionsProvider.notifier).updatePosition(
              project.id,
              clamped,
            );
      },
      onToggleExpand: () {
        setState(() {
          _expandedProjectId =
              _expandedProjectId == project.id ? null : project.id;
        });
      },
      rotationAngle: (index * math.pi / 8) % (2 * math.pi),
    );
  }

  Size _getBubbleSize(DeviceSpec deviceSpec, double baseSize) {
    final scale = baseSize / 120;
    return Size(
      deviceSpec.size.width * scale,
      deviceSpec.size.height * scale,
    );
  }

  DeviceSpec _getDeviceSpecForProject(ProjectInfo project) {
    final platforms =
        project.platform?.map((e) => e.toLowerCase()).toList() ?? [];
    if (platforms.contains('watch')) return DeviceSpec.watch();
    if (platforms.contains('smartphone')) return DeviceSpec.smartphone();
    if (platforms.contains('tablet')) return DeviceSpec.tablet();
    if (platforms.contains('desktop')) return DeviceSpec.desktop();
    if (platforms.contains('largedesktop')) return DeviceSpec.largeDesktop();
    return DeviceSpec.smartphone();
  }

  /// Taille des devices selon la largeur d'écran.
  /// Mobile (< 600px) : 50px → devices miniatures mais reconnaissables.
  /// Petite tablette (600–900px) : 70px.
  /// Grande tablette (900–1200px) : 92px.
  /// Desktop : 115–130px.
  BubbleLayoutSpec _calculateBubbleLayout(Size screenSize, int projectCount) {
    final w = screenSize.width;

    double baseSize;
    int cols;

    if (w < 400) {
      baseSize = 46;
      cols = 3;
    } else if (w < 600) {
      baseSize = 54;
      cols = 3;
    } else if (w < 768) {
      baseSize = 64;
      cols = 4;
    } else if (w < 900) {
      baseSize = 74;
      cols = 4;
    } else if (w < 1200) {
      baseSize = 92;
      cols = _calculateColumns(w, 92, projectCount);
    } else if (w < 1600) {
      baseSize = 115;
      cols = _calculateColumns(w, 115, projectCount);
    } else {
      baseSize = 130;
      cols = _calculateColumns(w, 130, projectCount);
    }

    final rows = (projectCount / cols).ceil();
    final padding = w < 600 ? 8.0 : (w < 900 ? 12.0 : 18.0);

    // Contrainte supplémentaire : ne pas dépasser l'espace disponible
    final maxBubbleWidth = (screenSize.width - (cols + 1) * padding) / cols;
    final maxBubbleHeight = (screenSize.height - (rows + 1) * padding) / rows;
    final adjustedSize = math.min(
      baseSize,
      math.min(maxBubbleWidth * 0.88, maxBubbleHeight * 0.88),
    );

    return BubbleLayoutSpec(
      size: adjustedSize.clamp(38.0, 140.0),
      cols: cols,
      rows: rows,
      padding: padding,
    );
  }

  int _calculateColumns(
      double screenWidth, double bubbleSize, int projectCount) {
    if (screenWidth < 1200) return 4;
    if (screenWidth < 1600) return 5;
    final maxCols = (screenWidth / (bubbleSize * 2)).floor();
    return math.min(
        maxCols, math.max(5, (math.sqrt(projectCount * 1.5)).ceil()));
  }

  Offset _getInitialPosition(
    int index,
    int totalCount,
    Size screenSize,
    BubbleLayoutSpec spec,
    Size bubbleSize,
  ) {
    final col = index % spec.cols;
    final row = index ~/ spec.cols;
    final avgBubbleWidth = spec.size * 1.5;
    final avgBubbleHeight = spec.size * 2;
    final totalGridWidth =
        spec.cols * avgBubbleWidth + (spec.cols - 1) * spec.padding;
    final totalGridHeight =
        spec.rows * avgBubbleHeight + (spec.rows - 1) * spec.padding;
    final startX =
        math.max(spec.padding, (screenSize.width - totalGridWidth) / 2);
    final startY =
        math.max(spec.padding, (screenSize.height - totalGridHeight) / 2);
    final x = startX + col * (avgBubbleWidth + spec.padding);
    final y = startY + row * (avgBubbleHeight + spec.padding);
    final random = math.Random(index * 42);
    final jitterX = (random.nextDouble() - 0.5) * spec.padding * 0.5;
    final jitterY = (random.nextDouble() - 0.5) * spec.padding * 0.5;
    return Offset(
      (x + jitterX).clamp(
          spec.padding, screenSize.width - bubbleSize.width - spec.padding),
      (y + jitterY).clamp(
          spec.padding, screenSize.height - bubbleSize.height - spec.padding),
    );
  }

  Offset _clampPosition(Offset position, Size screenSize, Size bubbleSize) {
    return Offset(
      position.dx.clamp(0.0, math.max(0, screenSize.width - bubbleSize.width)),
      position.dy
          .clamp(0.0, math.max(0, screenSize.height - bubbleSize.height)),
    );
  }

  void _redistributeBubbles(Size newSize) {
    final bubbleSpecs = _calculateBubbleLayout(newSize, widget.projects.length);
    final notifier = ref.read(projectPositionsProvider.notifier);
    final List<Offset> assignedPositions = [];
    for (int i = 0; i < widget.projects.length; i++) {
      final project = widget.projects[i];
      final deviceSpec = _getDeviceSpecForProject(project);
      final bubbleSize = _getBubbleSize(deviceSpec, bubbleSpecs.size);
      var newPosition = _getInitialPosition(
          i, widget.projects.length, newSize, bubbleSpecs, bubbleSize);
      newPosition = _resolveCollisions(newPosition, bubbleSize,
          assignedPositions, newSize, bubbleSpecs.size);
      assignedPositions.add(newPosition);
      notifier.updatePosition(project.id, newPosition);
    }
  }

  Offset _resolveCollisions(
    Offset position,
    Size currentBubbleSize,
    List<Offset> existingPositions,
    Size screenSize,
    double avgBubbleSize,
  ) {
    var resolvedPosition = position;
    const maxAttempts = 100;
    var attempts = 0;
    while (attempts < maxAttempts) {
      bool hasCollision = false;
      for (final otherPos in existingPositions) {
        final dx = (resolvedPosition.dx - otherPos.dx).abs();
        final dy = (resolvedPosition.dy - otherPos.dy).abs();
        final minDistX = currentBubbleSize.width * 0.6 + avgBubbleSize * 0.6;
        final minDistY = currentBubbleSize.height * 0.6 + avgBubbleSize * 0.6;
        if (dx < minDistX && dy < minDistY) {
          hasCollision = true;
          final angle = attempts * 0.5;
          final distance = avgBubbleSize * 1.5 * (1 + attempts * 0.1);
          final offset = Offset(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          );
          resolvedPosition =
              _clampPosition(position + offset, screenSize, currentBubbleSize);
          break;
        }
      }
      if (!hasCollision) break;
      attempts++;
    }
    return resolvedPosition;
  }
}

class BubbleLayoutSpec {
  final double size;
  final int cols;
  final int rows;
  final double padding;
  const BubbleLayoutSpec({
    required this.size,
    required this.cols,
    required this.rows,
    required this.padding,
  });
}
