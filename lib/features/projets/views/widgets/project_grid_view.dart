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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Détection du changement significatif de taille
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

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < widget.projects.length; i++)
              _buildBubble(
                i,
                screenSize,
                bubbleSpecs,
                positions,
              ),
          ],
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
      isSelected: widget.selected.any((p) => p.id == project.id),
      initialOffset: positions[project.id] ??
          _getInitialPosition(
            index,
            widget.projects.length,
            screenSize,
            spec,
            bubbleSize,
          ),
      onPositionChanged: (offset) {
        final clamped = _clampPosition(
          offset,
          screenSize,
          bubbleSize,
        );
        ref.read(projectPositionsProvider.notifier).updatePosition(
              project.id,
              clamped,
            );
      },
      rotationAngle: (index * math.pi / 8) % (2 * math.pi),
    );
  }

  /// Obtient la taille réelle d'une bulle selon le type d'appareil
  Size _getBubbleSize(DeviceSpec deviceSpec, double baseSize) {
    // Les specs du device sont en taille fixe, on les scale selon baseSize
    final scale =
        baseSize / 120; // 120 est la taille de référence d'un smartphone
    return Size(
      deviceSpec.size.width * scale,
      deviceSpec.size.height * scale,
    );
  }

  /// Détermine le type d'appareil pour un projet
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

  /// Calcule la disposition optimale des bulles selon la taille d'écran
  BubbleLayoutSpec _calculateBubbleLayout(Size screenSize, int projectCount) {
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width < 900;
    final isLargeScreen = screenSize.width < 1400;

    // Taille de base des bulles (référence pour un smartphone)
    double baseSize;
    if (isSmallScreen) {
      baseSize = 80;
    } else if (isMediumScreen) {
      baseSize = 100;
    } else if (isLargeScreen) {
      baseSize = 120;
    } else {
      baseSize = 140;
    }

    // Calculer le nombre de colonnes
    final cols = _calculateColumns(screenSize.width, baseSize, projectCount);
    final rows = (projectCount / cols).ceil();

    // Ajuster la taille si nécessaire pour éviter le débordement
    final padding = isSmallScreen ? 15.0 : 20.0;
    final maxBubbleWidth = (screenSize.width - (cols + 1) * padding) / cols;
    final maxBubbleHeight = (screenSize.height - (rows + 1) * padding) / rows;

    // Prendre en compte que certains devices sont plus larges/hauts
    final adjustedSize = math.min(
      baseSize,
      math.min(maxBubbleWidth * 0.8, maxBubbleHeight * 0.8),
    );

    return BubbleLayoutSpec(
      size: adjustedSize,
      cols: cols,
      rows: rows,
      padding: padding,
    );
  }

  /// Calcule le nombre optimal de colonnes
  int _calculateColumns(
      double screenWidth, double bubbleSize, int projectCount) {
    if (screenWidth < 500) return 2;
    if (screenWidth < 800) return 3;
    if (screenWidth < 1200) return 4;
    if (screenWidth < 1600) return 5;

    // Pour les très grands écrans
    final maxCols = (screenWidth / (bubbleSize * 2)).floor();
    return math.min(
        maxCols, math.max(5, (math.sqrt(projectCount * 1.5)).ceil()));
  }

  /// Obtient la position initiale pour une bulle selon une grille
  Offset _getInitialPosition(
    int index,
    int totalCount,
    Size screenSize,
    BubbleLayoutSpec spec,
    Size bubbleSize,
  ) {
    final col = index % spec.cols;
    final row = index ~/ spec.cols;

    // Calculer les dimensions de la grille avec les vraies tailles de bulles
    final avgBubbleWidth = spec.size * 1.5; // Marge pour devices larges
    final avgBubbleHeight = spec.size * 2; // Marge pour devices hauts

    final totalGridWidth =
        spec.cols * avgBubbleWidth + (spec.cols - 1) * spec.padding;
    final totalGridHeight =
        spec.rows * avgBubbleHeight + (spec.rows - 1) * spec.padding;

    // Centrer la grille
    final startX =
        math.max(spec.padding, (screenSize.width - totalGridWidth) / 2);
    final startY =
        math.max(spec.padding, (screenSize.height - totalGridHeight) / 2);

    final x = startX + col * (avgBubbleWidth + spec.padding);
    final y = startY + row * (avgBubbleHeight + spec.padding);

    // Ajouter une légère variation pour un effet naturel
    final random = math.Random(index * 42); // Seed fixe pour cohérence
    final jitterX = (random.nextDouble() - 0.5) * spec.padding * 0.5;
    final jitterY = (random.nextDouble() - 0.5) * spec.padding * 0.5;

    return Offset(
      (x + jitterX).clamp(
          spec.padding, screenSize.width - bubbleSize.width - spec.padding),
      (y + jitterY).clamp(
          spec.padding, screenSize.height - bubbleSize.height - spec.padding),
    );
  }

  /// Limite la position pour qu'elle reste dans l'écran
  Offset _clampPosition(Offset position, Size screenSize, Size bubbleSize) {
    return Offset(
      position.dx.clamp(0.0, math.max(0, screenSize.width - bubbleSize.width)),
      position.dy
          .clamp(0.0, math.max(0, screenSize.height - bubbleSize.height)),
    );
  }

  /// Redistribue toutes les bulles lors du redimensionnement
  void _redistributeBubbles(Size newSize) {
    final bubbleSpecs = _calculateBubbleLayout(
      newSize,
      widget.projects.length,
    );

    final notifier = ref.read(projectPositionsProvider.notifier);
    final List<Offset> assignedPositions = [];

    for (int i = 0; i < widget.projects.length; i++) {
      final project = widget.projects[i];
      final deviceSpec = _getDeviceSpecForProject(project);
      final bubbleSize = _getBubbleSize(deviceSpec, bubbleSpecs.size);

      var newPosition = _getInitialPosition(
        i,
        widget.projects.length,
        newSize,
        bubbleSpecs,
        bubbleSize,
      );

      // Résoudre les collisions avec les bulles déjà placées
      newPosition = _resolveCollisions(
        newPosition,
        bubbleSize,
        assignedPositions,
        newSize,
        bubbleSpecs.size,
      );

      assignedPositions.add(newPosition);
      notifier.updatePosition(project.id, newPosition);
    }
  }

  /// Résout les collisions entre bulles
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

        // Distance minimale = somme des rayons + marge
        final minDistX = currentBubbleSize.width * 0.6 + avgBubbleSize * 0.6;
        final minDistY = currentBubbleSize.height * 0.6 + avgBubbleSize * 0.6;

        if (dx < minDistX && dy < minDistY) {
          hasCollision = true;

          // Pousser dans une direction spirale
          final angle = attempts * 0.5;
          final distance = avgBubbleSize * 1.5 * (1 + attempts * 0.1);

          final offset = Offset(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          );

          resolvedPosition = _clampPosition(
            position + offset,
            screenSize,
            currentBubbleSize,
          );
          break;
        }
      }

      if (!hasCollision) break;
      attempts++;
    }

    return resolvedPosition;
  }
}

/// Spécifications de disposition des bulles
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
