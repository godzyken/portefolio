import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/affichage/screen_size_detector.dart';

class AdaptiveCard extends ConsumerWidget {
  final String title;
  final List<String> bulletPoints;
  final String? imagePath;
  final VoidCallback? onTap;
  final List<Widget>? trailingActions;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    this.imagePath,
    this.onTap,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ref.watch(isDesktopProvider);

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        clipBehavior: Clip.hardEdge,
        child: isDesktop
            ? _horizontal(context, isDesktop)
            : _vertical(context, isDesktop),
      ),
    );
  }

  // ---------------------- Vertical layout (mobile / tablet) ------------------
  Widget _vertical(BuildContext ctx, bool isDesktop) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        fit: StackFit.loose,
        children: [
          _backgroundImage(isDesktop),
          _gradientOverlay(),
          // Le texte devient scrollable si nécessaire
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _textContent(ctx, isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

// --- Horizontal (desktop) ---
  Widget _horizontal(BuildContext ctx, bool isDesktop) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // Grille ⇒ maxHeight FINI (sinon on lui donne un ratio fixe)
        final maxH = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : constraints.maxWidth * 1.1; // fallback raisonnable

        return SizedBox(
          height: maxH,
          child: Row(
            children: [
              // -------------------------------------------------------------------
              Flexible(
                // ou Expanded(flex:2)
                flex: 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _backgroundImage(isDesktop),
                    _gradientOverlay(),
                  ],
                ),
              ),
              const SizedBox(width: 8), // petite marge optionnelle
              // -------------------------------------------------------------------
              Flexible(
                // ou Expanded(flex:3)
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _textContent(ctx, isDesktop),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------- Common text content --------------------------------
  Widget _textContent(BuildContext ctx, bool isDesktop) {
    final theme = Theme.of(ctx);
    final bulletsToShow = bulletPoints.take(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Title ----------------------------------------------------------
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDesktop ? Colors.indigoAccent : Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),

        // --- Bullets --------------------------------------------------------
        ...bulletsToShow.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                p,
                softWrap: true,
                style: TextStyle(
                  color: isDesktop ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16 : 14,
                ),
              ),
            )),
        if (bulletPoints.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${bulletPoints.length - 3} autres…',
              style:
                  TextStyle(color: isDesktop ? Colors.black87 : Colors.white70),
            ),
          ),

        const SizedBox(height: 12),

        // --- Footer actions -------------------------------------------------
        Align(
          alignment: Alignment.centerRight,
          child: trailingActions != null
              ? Wrap(spacing: 4, children: trailingActions!)
              : Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Icon(Icons.touch_app,
                        color: isDesktop ? Colors.black87 : Colors.white70,
                        size: 16),
                    Text('Cliquer pour voir plus',
                        style: TextStyle(
                            color:
                                isDesktop ? Colors.black87 : Colors.white70)),
                  ],
                ),
        ),
      ],
    );
  }

  // ---------------------- Helpers -------------------------------------------
  Widget _backgroundImage(bool isDesktop) {
    if (imagePath == null) return const SizedBox.expand();
    return ColorFiltered(
      colorFilter: isDesktop
          ? ColorFilter.mode(
              Colors.black38.withAlpha((255 * 0.2).toInt()),
              BlendMode.colorBurn,
            )
          : ColorFilter.mode(
              Colors.black38.withAlpha((255 * 0.6).toInt()),
              BlendMode.colorBurn,
            ),
      child: Image.asset(imagePath!, fit: BoxFit.contain),
    );
  }

  Widget _gradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown, Colors.black12, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.5, 1],
        ),
      ),
    );
  }
}
