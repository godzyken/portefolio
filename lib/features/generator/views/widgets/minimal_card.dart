import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'immersive_detail_screen.dart';

class MinimalCard extends ConsumerStatefulWidget {
  final String title;
  final List<String> bulletPoints;
  final List<String>? images;
  final IconData? fallbackIcon;

  const MinimalCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    this.images,
    this.fallbackIcon,
  });

  @override
  ConsumerState<MinimalCard> createState() => _MinimalCardState();
}

class _MinimalCardState extends ConsumerState<MinimalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _showImmersiveDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          transform: Matrix4.identity()
            ..scaledByVector3(Vector3.all(_isHovered ? 1.05 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? theme.colorScheme.primary.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 10 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond avec zoom
                AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: _buildBackground(theme),
                ),

                // Overlay gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: _isHovered ? 0.8 : 0.7),
                      ],
                    ),
                  ),
                ),

                // Titre en bas
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: _isHovered
                          ? (info.isMobile ? 18 : 22)
                          : (info.isMobile ? 16 : 20),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Icône d'action
                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? theme.colorScheme.primary.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: _isHovered ? 24 : 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    if (widget.images != null && widget.images!.isNotEmpty) {
      return SmartImage(
        path: widget.images!.first,
        fit: BoxFit.cover,
        fallbackIcon: widget.fallbackIcon,
        fallbackColor: theme.colorScheme.primary,
      );
    }

    // Fallback avec gradient
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon ?? Icons.image,
          size: 64,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _showImmersiveDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImmersiveDetailScreen(
              title: widget.title,
              bulletPoints: widget.bulletPoints,
              images: widget.images,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
