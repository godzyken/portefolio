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
  // Références vers le Data Binding (View Model)
  ViewModelInstanceBoolean? _isTalkingBind;
  ViewModelInstanceBoolean? _isThinkingBind;
  ViewModelInstanceNumber? _stateIndexBind;

  void _onLoaded(RiveLoaded loaded) {
    debugPrint('🎬 [AvatarDisplay] Chargé : Artboard="${loaded.controller.artboard.name}"');
    
    // 🔗 RÉCUPÉRATION DU VIEW MODEL (Data Binding)
    final viewModel = loaded.viewModelInstance;
    
    if (viewModel != null) {
      debugPrint('🔗 [AvatarDisplay] Data Binding Rive détecté');
      
      _isTalkingBind = viewModel.boolean('isTalking') ?? viewModel.boolean('talking');
      _isThinkingBind = viewModel.boolean('isThinking') ?? viewModel.boolean('thinking');
      _stateIndexBind = viewModel.number('State');
      
      if (_stateIndexBind != null) {
        _stateIndexBind!.value = 1.0;
      }
    } else {
      debugPrint('⚠️ [AvatarDisplay] Aucun View Model trouvé. Utilisation des inputs classiques.');
      final stateMachine = loaded.controller.stateMachine;
      // On pourrait lier des inputs ici si nécessaire
    }
    
    _updateState();
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    _isTalkingBind?.value = widget.state == AvatarState.talking;
    _isThinkingBind?.value = widget.state == AvatarState.thinking;
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: FileLoader.fromAsset(
        widget.rivAsset,
        // ✅ On passe en Factory.flutter pour une compatibilité maximale sur le Web
        riveFactory: Factory.flutter,
      ),
      // 🪄 ACTIVATION DU DATA BINDING AUTOMATIQUE
      dataBind: const AutoBind(),
      
      // ✅ On laisse l'Artboard par défaut ou on cherche "soldier selection" qui semblait fonctionner
      artboardSelector: const ArtboardNamed('soldier selection'),
      stateMachineSelector: const StateMachineNamed('Two mercenaries'),
      
      onLoaded: _onLoaded,
      builder: (context, state) {
        if (state is RiveLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorHelpers.cyan),
          );
        }
        
        if (state is RiveLoaded) {
          return RiveWidget(
            controller: state.controller,
            fit: Fit.cover,
            alignment: Alignment.center,
          );
        }
        
        if (state is RiveFailed) {
          debugPrint('❌ [AvatarDisplay] Erreur : ${state.error}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                const SizedBox(height: 8),
                Text('Erreur Rive: ${state.error}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
