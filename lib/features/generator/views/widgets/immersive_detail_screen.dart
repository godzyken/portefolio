import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/features/parametres/views/widgets/smart_image.dart';

import '../../../projets/data/project_data.dart';
import 'particle_background.dart';

class ImmersiveDetailScreen extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final VoidCallback? onClose;

  const ImmersiveDetailScreen({
    super.key,
    required this.project,
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
        setState(() => _scrollOffset = _scrollController.offset);
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

    // Rotation automatique d’images
    if (widget.project.image != null && widget.project.image!.length > 1) {
      Future.delayed(const Duration(seconds: 5), _rotateImage);
    }
  }

  void _rotateImage() {
    if (!mounted || widget.project.image == null) return;
    setState(() {
      _currentImageIndex =
          (_currentImageIndex + 1) % widget.project.image!.length;
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
    final randomImage = _getCurrentImage();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🖼️ Background immersif
          if (randomImage != null)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, _scrollOffset * 0.5),
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

          // 🔲 Overlay sombre
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

          // ✨ Particules animées
          const Positioned.fill(
            child: ParticleBackground(
              particleCount: 40,
              particleColor: Colors.white,
              minSize: 1.5,
              maxSize: 4.0,
            ),
          ),

          // 🧱 Contenu principal
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
                      _buildTitle(theme, info),
                      SizedBox(height: info.isMobile ? 32 : 48),
                      _buildSection(
                          "📜 Description", widget.project.points, theme, info),
                      if (widget.project.techDetails != null &&
                          widget.project.techDetails!.isNotEmpty) ...[
                        SizedBox(height: 32),
                        _buildTechDetails(
                            widget.project.techDetails!, theme, info),
                      ],
                      if (widget.project.results != null &&
                          widget.project.results!.isNotEmpty) ...[
                        SizedBox(height: 32),
                        _buildSection("🏁 Résultats & livrables",
                            widget.project.results!, theme, info),
                      ],
                      if (randomImage != null) ...[
                        SizedBox(height: 48),
                        _buildImageCarousel(info),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ❌ Bouton fermer
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
        ],
      ),
    );
  }

  // ---------------- Widgets de contenu ---------------- //

  Widget _buildTitle(ThemeData theme, ResponsiveInfo info) {
    return Container(
      padding: EdgeInsets.all(info.isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
      ),
      child: Text(
        widget.project.title,
        style: theme.textTheme.displayMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: info.isMobile ? 28 : 48,
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> points, ThemeData theme, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(info.isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points.map((text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: info.isMobile ? 16 : 18,
                    height: 1.6,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTechDetails(
      Map<String, dynamic> details, ThemeData theme, ResponsiveInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "⚙️ Détails techniques",
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: info.isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(info.isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "• ${entry.key}: ",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: info.isMobile ? 16 : 18,
                        ),
                      ),
                      TextSpan(
                        text: "${entry.value}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: info.isMobile ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(ResponsiveInfo info) {
    final image = _getCurrentImage();
    if (image == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SmartImage(
        key: ValueKey(image),
        path: image,
        fit: BoxFit.cover,
        width: info.isMobile ? info.size.shortestSide : info.size.longestSide,
        height: info.isMobile ? info.size.shortestSide : info.size.longestSide,
      ),
    );
  }

  String? _getCurrentImage() {
    final images = widget.project.cleanedImages ?? widget.project.image;
    if (images == null || images.isEmpty) return null;
    return images[_currentImageIndex % images.length];
  }
}
