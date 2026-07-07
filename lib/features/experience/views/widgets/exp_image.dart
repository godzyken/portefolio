import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/experience/data/experiences_data.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/ui/widgets/smart_image.dart';
import '../painters/scanline_painter.dart';

class ExpImage extends ConsumerWidget {
  const ExpImage({super.key, required this.exp});
  final Experience exp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exp.image.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorHelpers.border),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartImage(
                path: exp.image,
                responsiveSize: ResponsiveImageSize.xlarge,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                enableShimmer: true,
                autoPreload: true,
                color: Colors.white.withValues(alpha: 0.9),
                colorBlendMode: BlendMode.modulate,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ColorHelpers.surface.withValues(alpha: 0.55)
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              CustomPaint(painter: ScanLinePainter()),
            ],
          ),
        ),
      ),
    );
  }
}
