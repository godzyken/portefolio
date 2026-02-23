import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/provider/image_providers.dart';

class CharacterViewer extends ConsumerStatefulWidget {
  const CharacterViewer({super.key});

  @override
  ConsumerState<CharacterViewer> createState() => _CharacterViewerState();
}

class _CharacterViewerState extends ConsumerState<CharacterViewer> {
  late String _currentModelPath;

  @override
  void initState() {
    super.initState();
    // On lit une seule fois au démarrage
    _currentModelPath = ref.read(characterModelProvider);
  }

  @override
  Widget build(BuildContext context) {
    // On écoute sans rebuild le provider
    ref.listen<String>(characterModelProvider, (prev, next) {
      if (next != prev && mounted) {
        setState(() => _currentModelPath = next);
      }
    });

    try {
      return ModelViewer(
        key: ValueKey(_currentModelPath),
        src: _currentModelPath,
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
    } catch (e) {
      developer.log('⚠️ Erreur ModelViewer: $e');
      return const SizedBox.shrink();
    }
  }
}
