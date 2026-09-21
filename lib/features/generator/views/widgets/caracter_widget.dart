import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  bool _isDelayedRender = false;

  @override
  void initState() {
    super.initState();
    // On lit une seule fois au démarrage
    _currentModelPath = ref.read(characterModelProvider);

    // ✅ Délai asynchrone pour laisser respirer le thread de rendu principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _isDelayedRender = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // On écoute sans rebuild le provider
    ref.listen<String>(characterModelProvider, (prev, next) {
      if (next != prev && mounted) {
        setState(() => _currentModelPath = next);
      }
    });

    // ✅ Éviter le chargement de ModelViewer (WebView interne) en mode de test de widget
    // pour empêcher le time-out perpétuel de tester.pumpAndSettle()
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      return const SizedBox.shrink();
    }

    if (!_isDelayedRender) {
      return const SizedBox.shrink();
    }

    try {
      return ModelViewer(
        key: ValueKey(_currentModelPath),
        src: _currentModelPath,
        alt: "Mon personnage de portfolio en 3D",
        cameraControls: true,
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
