import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

import 'particle_background.dart';

class ImmersiveDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final List<String> bulletPoints;
  final List<String>? images;
  final VoidCallback? onClose;

  const ImmersiveDetailScreen({
    super.key,
    required this.title,
    required this.bulletPoints,
    this.images,
    this.onClose,
  });

  @override
  ConsumerState<ImmersiveDetailScreen> createState() =>
      _ImmersiveDetailScreenState();
}

class _ImmersiveDetailScreenState extends ConsumerState<ImmersiveDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  int _currentImageIndex = 0;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // Rotation automatique des images
    if (widget.images != null && widget.images!.length > 1) {
      Future.delayed(const Duration(seconds: 5), _rotateImage);
    }
  }

  void _rotateImage() {
    if (!mounted || widget.images == null) return;

    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.images!.length;
    });

    Future.delayed(const Duration(seconds: 5), _rotateImage);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final randomImage = _getRandomImage();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background avec image aléatoire et effet parallaxe
          if (randomImage != null)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, _scrollOffset * 0.5), // Effet parallaxe
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: SmartImage(
                    key: ValueKey(randomImage),
                    path: randomImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Overlay sombre pour lisibilité
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          // Particules animées
          const Positioned.fill(
            child: ParticleBackground(
              particleCount: 40,
              particleColor: Colors.white,
              minSize: 1.5,
              maxSize: 4.0,
            ),
          ),

          // Contenu
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(info.isMobile ? 24 : 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre avec effet glassmorphism
                      _buildTitle(theme, info),

                      SizedBox(height: info.isMobile ? 32 : 48),

                      // Contenu principal
                      _buildContent(theme, info),

                      SizedBox(height: info.isMobile ? 24 : 32),

                      // Image si disponible
                      if (randomImage != null) _buildImagePreview(info),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bouton fermer
          Positioned(
            top: 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IconButton(
                icon: const Icon(Icons.close, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _controller.reverse().then((_) {
                    widget.onClose?.call();
                    if (mounted) Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ),

          // Indicateurs d'images
          if (widget.images != null && widget.images!.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _buildImageIndicators(),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Text(
        widget.title,
        style: theme.textTheme.displayMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: info.isMobile ? 28 : 48,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.bulletPoints.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 16),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: info.isMobile ? 16 : 18,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreview(ResponsiveInfo info) {
    final randomImage = _getRandomImage();
    if (randomImage == null) return const SizedBox.shrink();

    return Container(
      height: info.isMobile ? 250 : 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SmartImage(
                key: ValueKey(randomImage),
                path: randomImage,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Contrôles du carrousel
          if (widget.images != null && widget.images!.length > 1) ...[
            // Bouton précédent
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentImageIndex =
                          (_currentImageIndex - 1) % widget.images!.length;
                      if (_currentImageIndex < 0) {
                        _currentImageIndex = widget.images!.length - 1;
                      }
                    });
                  },
                ),
              ),
            ),

            // Bouton suivant
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentImageIndex =
                          (_currentImageIndex + 1) % widget.images!.length;
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageIndicators() {
    if (widget.images == null || widget.images!.length <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images!.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentImageIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentImageIndex
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  String? _getRandomImage() {
    if (widget.images == null || widget.images!.isEmpty) {
      return null;
    }

    if (widget.images!.length == 1) {
      return widget.images!.first;
    }

    // Utiliser l'index actuel plutôt qu'un random pour une rotation contrôlée
    return widget.images![_currentImageIndex];
  }
}
