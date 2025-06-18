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
        child: isDesktop ? _horizontal(context) : _vertical(context),
      ),
    );
  }

  // ---------------------- Vertical layout (mobile / tablet) ------------------
  Widget _vertical(BuildContext ctx) {
    return Stack(
      children: [
        _backgroundImage(),
        _gradientOverlay(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _textContent(ctx),
        ),
      ],
    );
  }

  // ---------------------- Horizontal layout (desktop) ------------------------
  Widget _horizontal(BuildContext ctx) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Stack(children: [
            _backgroundImage(),
            _gradientOverlay(),
          ]),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _textContent(ctx),
          ),
        ),
      ],
    );
  }

  // ---------------------- Common text content --------------------------------
  Widget _textContent(BuildContext ctx) {
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
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),

        // --- Bullets --------------------------------------------------------
        ...bulletsToShow.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• $p',
                softWrap: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        if (bulletPoints.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${bulletPoints.length - 3} autres…',
              style: const TextStyle(color: Colors.white70),
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
                  children: const [
                    Icon(Icons.touch_app, color: Colors.white70, size: 16),
                    Text('Cliquer pour voir plus',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
        ),
      ],
    );
  }

  // ---------------------- Helpers -------------------------------------------
  Widget _backgroundImage() {
    if (imagePath == null) return const SizedBox.expand();
    return Positioned.fill(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.indigoAccent.withAlpha((255 * 0.2).toInt()),
          BlendMode.colorBurn,
        ),
        child: Image.asset(imagePath!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _gradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.black12, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.5, 1],
          ),
        ),
      ),
    );
  }
}
