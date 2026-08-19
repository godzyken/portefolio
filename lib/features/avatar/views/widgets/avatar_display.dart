import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

enum AvatarState { idle, talking, thinking }

/// Widget d'affichage de l'Avatar utilisant le Data Binding de Rive 0.14.x.
class AvatarDisplay extends ConsumerStatefulWidget {
  final AvatarState state;
  final String rivAsset;

  const AvatarDisplay({
    super.key,
    this.state = AvatarState.idle,
    this.rivAsset = 'assets/images/animations/avatar_animate.riv',
  });

  @override
  ConsumerState<AvatarDisplay> createState() => _AvatarDisplayState();
}

class _AvatarDisplayState extends ConsumerState<AvatarDisplay> {
  // On n'utilise PLUS de variables late ou de références persistantes risquées
  
  void _onLoaded(RiveLoaded loaded) {
    debugPrint('🎬 [AvatarDisplay] Artboard "${loaded.controller.artboard.name}" chargé');
    _applySync(loaded);
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On ne fait rien ici, la synchronisation se fera au build via le controller
  }

  void _applySync(RiveLoaded loaded) {
    final viewModel = loaded.viewModelInstance;
    if (viewModel == null) return;

    // Synchronisation directe et sécurisée
    try {
      final talking = viewModel.boolean('isTalking') ?? viewModel.boolean('talking');
      final thinking = viewModel.boolean('isThinking') ?? viewModel.boolean('thinking');
      final stateIdx = viewModel.number('State');

      talking?.value = widget.state == AvatarState.talking;
      thinking?.value = widget.state == AvatarState.thinking;
      if (stateIdx != null && stateIdx.value == 0) {
        stateIdx.value = 1.0;
      }
    } catch (e) {
      debugPrint('⚠️ [AvatarDisplay] Erreur sync DataBinding : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: FileLoader.fromAsset(
        widget.rivAsset,
        riveFactory: Factory.flutter, // Stable sur Web
      ),
      dataBind: const AutoBind(),
      artboardSelector: const ArtboardNamed('soldier selection'),
      stateMachineSelector: const StateMachineNamed('Two mercenaries'),
      onLoaded: _onLoaded,
      builder: (context, state) {
        if (state is RiveLoading) {
          return const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));
        }
        
        if (state is RiveLoaded) {
          // 🔥 SYNCHRONISATION À CHAQUE REBUILD
          _applySync(state);
          
          return RiveWidget(
            controller: state.controller,
            fit: Fit.cover,
            alignment: Alignment.center,
          );
        }
        
        if (state is RiveFailed) {
          return const Center(child: Icon(Icons.error_outline, color: Colors.redAccent));
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
