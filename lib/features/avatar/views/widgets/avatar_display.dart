import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/config/assets_config.dart';

enum AvatarState { idle, talking, thinking }

/// Widget d'affichage de l'Avatar utilisant Rive 0.14.x.
class AvatarDisplay extends ConsumerStatefulWidget {
  final AvatarState state;
  final String rivAsset;

  const AvatarDisplay({
    super.key,
    this.state = AvatarState.idle,
    this.rivAsset = AssetsConfig.avatarRivePath,
  });

  @override
  ConsumerState<AvatarDisplay> createState() => _AvatarDisplayState();
}

class _AvatarDisplayState extends ConsumerState<AvatarDisplay> {
  // ✅ Utilisation des nouveaux types Rive 2
  BooleanInput? _isTalking;
  BooleanInput? _isThinking;
  NumberInput? _stateIndex;

  void _onLoaded(RiveLoaded loaded) {
    final sm = loaded.controller.stateMachine;

    // ✅ Accès aux inputs via les méthodes dédiées du moteur Rive 2
    _isTalking = sm.boolean('isTalking') ?? sm.boolean('talking');
    _isThinking = sm.boolean('isThinking') ?? sm.boolean('thinking');
    _stateIndex = sm.number('State') ?? sm.number('index');

    if (_stateIndex != null && _stateIndex!.value == 0) {
      _stateIndex!.value = 1.0;
    }

    _updateState();
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    // Mise à jour sécurisée des inputs
    final talking = _isTalking;
    final thinking = _isThinking;

    if (talking != null) {
      talking.value = widget.state == AvatarState.talking;
    }
    if (thinking != null) {
      thinking.value = widget.state == AvatarState.thinking;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: FileLoader.fromAsset(
        widget.rivAsset,
        riveFactory: Factory.flutter, // Stable sur Web
      ),
      // ⚠️ On retire AutoBind() pour éviter le crash LateInitialization
      artboardSelector: const ArtboardNamed('soldier selection'),
      stateMachineSelector: const StateMachineNamed('Two mercenaries'),
      onLoaded: _onLoaded,
      builder: (context, state) {
        if (state is RiveLoading) {
          return const Center(
              child: CircularProgressIndicator(color: ColorHelpers.cyan));
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
              child: Icon(Icons.error_outline, color: Colors.redAccent));
        }

        return const SizedBox.shrink();
      },
    );
  }
}
