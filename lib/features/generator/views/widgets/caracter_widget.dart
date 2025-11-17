import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/provider/image_providers.dart';

class CharacterViewer extends ConsumerWidget {
  const CharacterViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Écoutez l'état du provider
    final modelPathAsync = ref.watch(characterModelProvider);

    return ModelViewer(
      src: modelPathAsync,
      alt: "Mon personnage de portfolio en 3D",
      cameraControls: false,
      autoPlay: true,
      autoRotate: true,
      backgroundColor: Colors.transparent,
      cameraOrbit: '45deg 75deg 10m',
      fieldOfView: '40deg',
      loading: Loading.eager,
      reveal: Reveal.auto,
    );
  }
}
