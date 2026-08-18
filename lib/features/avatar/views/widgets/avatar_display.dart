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
    // 🔗 RÉCUPÉRATION DU VIEW MODEL (Data Binding)
    final viewModel = loaded.viewModelInstance;
    
    if (viewModel != null) {
      debugPrint('🔗 Data Binding Rive détecté');
      
      // Accès aux propriétés définies dans l'éditeur Rive
      _isTalkingBind = viewModel.boolean('isTalking') ?? viewModel.boolean('talking');
      _isThinkingBind = viewModel.boolean('isThinking') ?? viewModel.boolean('thinking');
      _stateIndexBind = viewModel.number('State');
      
      if (_stateIndexBind != null) {
        _stateIndexBind!.value = 1.0;
      }
    } else {
      debugPrint('⚠️ Aucun View Model trouvé. On se replie sur les inputs classiques.');
      final sm = loaded.controller.stateMachine;
      // On peut aussi lier des BooleanInput/NumberInput ici en secours
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
        riveFactory: Factory.rive,
      ),
      // 🪄 ACTIVATION DU DATA BINDING AUTOMATIQUE
      dataBind: const AutoBind(),
      
      artboardSelector: const ArtboardNamed('Soldier 1'),
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
          return const Center(
            child: Icon(Icons.error_outline, color: Colors.redAccent),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
