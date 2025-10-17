import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/bubble_menu_item.dart';

class BubbleNavigationMenu extends StatefulWidget {
  final List<BubbleMenuItem> items;
  final IconData activeIcon;
  final Alignment menuPosition;

  const BubbleNavigationMenu({
    super.key,
    required this.items,
    required this.activeIcon,
    this.menuPosition = Alignment.bottomRight,
  });

  @override
  State<BubbleNavigationMenu> createState() => _BubbleNavigationMenuState();
}

class _BubbleNavigationMenuState extends State<BubbleNavigationMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu({bool? forceClose}) {
    if (!mounted) return;
    setState(() {
      _isOpen = forceClose ?? !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bouclier transparent pour fermer le menu au clic externe
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _toggleMenu(forceClose: true),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),

        // Menu bubble positionné dans un coin
        _buildMenuPosition(),
      ],
    );
  }

  Widget _buildMenuPosition() {
    const double menuSize = 200.0;
    const double padding = 16.0;

    switch (widget.menuPosition) {
      case Alignment.bottomRight:
        return Positioned(
          bottom: padding,
          right: padding,
          child: _buildMenuContainer(),
        );
      case Alignment.bottomLeft:
        return Positioned(
          bottom: padding,
          left: padding,
          child: _buildMenuContainer(),
        );
      case Alignment.topRight:
        return Positioned(
          top: padding,
          right: padding,
          child: _buildMenuContainer(),
        );
      case Alignment.topLeft:
        return Positioned(
          top: padding,
          left: padding,
          child: _buildMenuContainer(),
        );
      default:
        return Positioned(
          bottom: padding,
          right: padding,
          child: _buildMenuContainer(),
        );
    }
  }

  Widget _buildMenuContainer() {
    const double menuSize = 200.0;

    return MouseRegion(
      onEnter: (_) => _toggleMenu(forceClose: false),
      onExit: (_) {
        if (_isOpen) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isOpen) {
              _toggleMenu(forceClose: true);
            }
          });
        }
      },
      child: SizedBox.square(
        dimension: menuSize,
        child: Flow(
          delegate: _BubbleMenuFlowDelegate(
            animation: _controller,
            position: widget.menuPosition,
          ),
          children: [
            // Bouton central (Home) - enfant 0
            _buildCentralButton(),

            // Les bulles de navigation - enfants 1+
            ...widget.items.map((item) => _buildBubble(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return FloatingActionButton(
      elevation: _isOpen ? 8.0 : 2.0,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(
            alpha: _isOpen ? 1.0 : 0.6,
          ),
      onPressed: _toggleMenu,
      child: AnimatedRotation(
        turns: _isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 300),
        child: Icon(
          _isOpen ? Icons.close : widget.activeIcon,
          size: 30,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildBubble(BubbleMenuItem item) {
    return FloatingActionButton(
      heroTag: item.label,
      mini: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () {
        _toggleMenu(forceClose: true);
        Future.delayed(const Duration(milliseconds: 50), () {
          item.onPressed();
        });
      },
      child: Tooltip(
        message: item.label,
        child:
            Icon(item.icon, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}

/// Gère le positionnement et l'animation en quart de cercle
class _BubbleMenuFlowDelegate extends FlowDelegate {
  final Animation<double> animation;
  final Alignment position;

  _BubbleMenuFlowDelegate({
    required this.animation,
    required this.position,
  }) : super(repaint: animation);

  @override
  void paintChildren(FlowPaintingContext context) {
    if (context.childCount == 0) return;

    final size = context.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Radius augmente avec l'animation
    final radius = 80.0 * animation.value;

    // L'index du bouton central (toujours enfant 0)
    final centralButtonSize = context.getChildSize(0);
    if (centralButtonSize == null) return;

    final itemCount = context.childCount - 1; // Nombre de bulles

    // Détermine l'angle de départ et la direction selon la position
    late double startAngle;
    late double sweepAngle;

    switch (position) {
      case Alignment.bottomRight:
        startAngle = math.pi; // Commence à gauche
        sweepAngle = -math.pi / 2; // Va vers le haut (quart de cercle)
        break;
      case Alignment.bottomLeft:
        startAngle = 0; // Commence à droite
        sweepAngle = -math.pi / 2; // Va vers le haut
        break;
      case Alignment.topRight:
        startAngle = math.pi; // Commence à gauche
        sweepAngle = math.pi / 2; // Va vers le bas
        break;
      case Alignment.topLeft:
        startAngle = 0; // Commence à droite
        sweepAngle = math.pi / 2; // Va vers le bas
        break;
      default:
        startAngle = -math.pi / 2;
        sweepAngle = math.pi / 2;
    }

    // Positionne le bouton central au centre
    context.paintChild(
      0,
      transform: Matrix4.translationValues(
        centerX - centralButtonSize.width / 2,
        centerY - centralButtonSize.height / 2,
        0,
      ),
    );

    // Positionne les bulles autour du centre en arc de cercle
    for (int i = 0; i < itemCount; i++) {
      final angle = startAngle +
          (sweepAngle *
              (itemCount > 1 ? i / (itemCount - 1) : 0.5)); // Répartition égale

      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      final childSize = context.getChildSize(i + 1);
      if (childSize == null) continue;

      context.paintChild(
        i + 1,
        transform: Matrix4.translationValues(
          x - childSize.width / 2,
          y - childSize.height / 2,
          0,
        ),
        opacity: animation.value,
      );
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // Retourne une taille basée sur les contraintes reçues
    // Si pas de contrainte, utilise 200x200
    return Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : 200,
      constraints.hasBoundedHeight ? constraints.maxHeight : 200,
    );
  }

  @override
  bool shouldRepaint(_BubbleMenuFlowDelegate oldDelegate) =>
      animation != oldDelegate.animation || position != oldDelegate.position;
}
