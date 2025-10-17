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
    const double menuSize = 180.0;

    return GestureDetector(
      onTap: () {
        if (_isOpen) _toggleMenu(forceClose: true);
      },
      child: SizedBox.square(
        dimension: menuSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bouclier transparent - couche dessous
            if (_isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _toggleMenu(forceClose: true),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),

            // Menu Flow
            MouseRegion(
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
              child: Flow(
                clipBehavior: Clip.none,
                delegate: _BubbleMenuFlowDelegate(
                  animation: _controller,
                  position: widget.menuPosition,
                ),
                children: [
                  _buildCentralButton(),
                  ...widget.items.map((item) => _buildBubble(item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return FloatingActionButton(
      elevation: _isOpen ? 8.0 : 2.0,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(
            alpha: _isOpen ? 1.0 : 0.4, // Transparent au repos
          ),
      onPressed: _toggleMenu,
      child: AnimatedRotation(
        turns: _isOpen ? 0.125 : 0,
        duration: const Duration(milliseconds: 300),
        child: Icon(
          _isOpen ? Icons.close : widget.activeIcon,
          size: 24,
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
    final radius = 70.0 * animation.value;

    final centralButtonSize = context.getChildSize(0);
    if (centralButtonSize == null) return;

    final itemCount = context.childCount - 1;

    // Quart de cercle (bas-gauche par défaut)
    double startAngle = 0;
    double sweepAngle = math.pi / 2;

    // Bouton central
    context.paintChild(
      0,
      transform: Matrix4.translationValues(
        centerX - centralButtonSize.width / 2,
        centerY - centralButtonSize.height / 2,
        0,
      ),
    );

    // Bulles autour
    for (int i = 0; i < itemCount; i++) {
      final angle = startAngle +
          (sweepAngle * (itemCount > 1 ? i / (itemCount - 1) : 0.5));

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
    return const Size(180, 180);
  }

  @override
  bool shouldRepaint(_BubbleMenuFlowDelegate oldDelegate) =>
      animation != oldDelegate.animation;
}
