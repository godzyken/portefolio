import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portefolio/core/provider/providers.dart';

import '../../../generator/views/widgets/code_high_light_list.dart';
import '../../../generator/views/widgets/hover_card.dart';
import '../../data/project_data.dart';

class ProjectBubble extends ConsumerStatefulWidget {
  final ProjectInfo project;
  final bool isSelected;

  const ProjectBubble({
    super.key,
    required this.project,
    required this.isSelected,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectBubbleState();
}

class _ProjectBubbleState extends ConsumerState<ProjectBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _screenCtrl;
  late final Animation<double> _screenAnim;
  int _currentImageIndex = 0;

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    // 🔹 Animation continue pour “live screen”
    _screenCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _screenAnim = CurvedAnimation(parent: _screenCtrl, curve: Curves.easeInOut);

    _screenCtrl.repeat(reverse: true);

    if (widget.project.image != null && widget.project.image!.length > 1) {
      Future.delayed(const Duration(seconds: 0), _nextImageLoop);
    }

    // 🔹 Scroll automatique simulé si l'image est plus grande que le conteneur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        final maxScroll = _scrollCtrl.position.maxScrollExtent;
        _scrollCtrl
            .animateTo(
              maxScroll,
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOut,
            )
            .then(
              (_) => _scrollCtrl.animateTo(
                0,
                duration: const Duration(seconds: 4),
                curve: Curves.easeInOut,
              ),
            );
      }
    });
  }

  void _nextImageLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      setState(() {
        _currentImageIndex =
            (_currentImageIndex + 1) % widget.project.image!.length;
      });
    }
  }

  @override
  void dispose() {
    _screenCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleSize = _getBubbleSize(widget.project);
    final borderRadius = _getBorderRadius(widget.project);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // === BULLE PRINCIPALE (ECRAN) ===
        Material(
          color: Colors.transparent,
          elevation: 8,
          child: HoverCard(
            id: widget.project.id,
            child: InkWell(
              onTap: () => _showProjectDialog(context, ref),
              borderRadius: borderRadius,
              child: AnimatedBuilder(
                animation: _screenAnim,
                builder: (_, _) {
                  return ClipRRect(
                    borderRadius: borderRadius,
                    child: Container(
                      width: bubbleSize.width,
                      height: bubbleSize.height,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 6,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child:
                          widget.project.image != null &&
                              widget.project.image!.isNotEmpty
                          ? _buildScreenContent(bubbleSize)
                          : const Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // === MINI BULLE FLOTTANTE POUR LE TITRE ===
        Positioned(
          right: -10,
          top: -30,
          child: Material(
            color: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.9).toInt()),
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                widget.project.title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ),
          ),
        ),

        // === QUEUE DE BULLE ===
        Positioned(
          left: 8,
          bottom: -6,
          child: CustomPaint(
            size: const Size(12, 12),
            painter: BubbleTailPainter(),
          ),
        ),

        // === ICÔNE DE SELECTION ===
        if (widget.isSelected)
          const Positioned(
            bottom: -10,
            right: -10,
            child: Icon(Icons.check_circle, color: Colors.green, size: 22),
          ),
      ],
    );
  }

  Widget _buildScreenContent(Size bubbleSize) {
    if (widget.project.image == null || widget.project.image!.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 40);
    }

    final imageUrl = widget.project.image![_currentImageIndex];

    return Stack(
      fit: StackFit.expand, // ✅ occupe toute la bulle
      children: [
        // Image pricipale
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  key: ValueKey(imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, size: 40),
                )
              : Image.asset(
                  imageUrl,
                  key: ValueKey(imageUrl),
                  fit: BoxFit.cover,
                ),
        ),

        // Overlay clignotant pour effet "écran actif"
        AnimatedBuilder(
          animation: _screenAnim,
          builder: (_, _) => Container(
            color: Colors.white.withAlpha((0.05 * _screenAnim.value).toInt()),
          ),
        ),
      ],
    );
  }

  // --- Taille des bulles en fonction du type de plateforme ---
  Size _getBubbleSize(ProjectInfo project) {
    if (project.platform!.contains('watch')) {
      return const Size(70, 70); // carré
    } else if (project.platform!.contains('Smartphone')) {
      return const Size(90, 160); // ratio 9:16 portrait
    } else if (project.platform!.contains('tablet')) {
      return const Size(120, 160); // ratio 3:4 portrait
    } else if (project.platform!.contains('Desktop')) {
      return const Size(180, 110); // ratio 16:9 paysage
    } else if (project.platform!.contains('LargeDesktop')) {
      return const Size(220, 130); // ratio 16:9 paysage large
    }
    return const Size(140, 140); // défaut carré
  }

  // --- Forme de l'écran avec coins arrondis différents ---
  BorderRadius _getBorderRadius(ProjectInfo project) {
    if (project.platform!.contains('watch')) {
      return BorderRadius.circular(50); // rond / montre
    } else if (project.platform!.contains('Smartphone')) {
      return BorderRadius.circular(20); // arrondi smartphone
    } else if (project.platform!.contains('tablet')) {
      return BorderRadius.circular(15);
    } else if (project.platform!.contains('Desktop') ||
        project.platform!.contains('LargeDesktop')) {
      return BorderRadius.circular(10); // plus rectangulaire
    }
    return BorderRadius.circular(12);
  }

  void _showProjectDialog(BuildContext context, WidgetRef ref) {
    final pdfService = ref.read(pdfExportProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          widget.project.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.project.image != null &&
                  widget.project.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.project.image!.first,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 16),
              CodeHighlightList(items: widget.project.points, tag: '->'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Fermer'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Imprimer ce projet'),
            onPressed: () => pdfService.export([widget.project]),
          ),
        ],
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
