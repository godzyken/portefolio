import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

enum AvatarState { idle, talking, thinking }

class AvatarDisplay extends StatefulWidget {
  final AvatarState state;
  final String rivAsset;

  const AvatarDisplay({
    super.key,
    this.state = AvatarState.idle,
    this.rivAsset = 'assets/images/animations/avatar_animate.riv',
  });

  @override
  State<AvatarDisplay> createState() => _AvatarDisplayState();
}

class _AvatarDisplayState extends State<AvatarDisplay> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<bool>? _isTalking;
  SMIInput<bool>? _isThinking;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  void _loadRive() {
    debugPrint('📥 [AvatarDisplay] Tentative : ${widget.rivAsset}');
    
    rootBundle.load(widget.rivAsset).then(
      (data) async {
        try {
          await RiveFile.initialize();
          final file = RiveFile.import(data);
          
          Artboard? targetArtboard;
          for (final artboard in file.artboards) {
            if (artboard.name.toLowerCase().contains('soldier') || 
                artboard.stateMachines.any((sm) => sm.name.toLowerCase().contains('mercenaries'))) {
              targetArtboard = artboard.instance();
              break;
            }
          }

          targetArtboard ??= file.mainArtboard.instance();

          // On cherche la machine à états
          final sm = targetArtboard.stateMachines.firstWhere(
            (sm) => sm.name.toLowerCase().contains('mercenaries') || sm.name == 'State Machine 1',
            orElse: () => targetArtboard!.stateMachines.first,
          );

          final controller = StateMachineController.fromArtboard(targetArtboard, sm.name);
          
          if (controller != null) {
            targetArtboard.addController(controller);
            
            for (var input in controller.inputs) {
              final name = input.name.toLowerCase();
              if (input is SMIInput<bool>) {
                if (name.contains('talk')) _isTalking = input;
                if (name.contains('think')) _isThinking = input;
              }
              // 🔥 ON FORCE L'AFFICHAGE DU MERCENAIRE
              if (name.contains('state') && input is SMIInput<double>) {
                input.value = 1.0; // On sélectionne le premier soldat
                debugPrint('🚀 [AvatarDisplay] State forcé à 1.0');
              }
            }
          }

          if (mounted) {
            setState(() {
              _riveArtboard = targetArtboard;
              _controller = controller; // On stocke pour le dispose
              _hasError = false;
            });
            _updateState();
            debugPrint('✅ [AvatarDisplay] Prêt sur Artboard: ${targetArtboard.name}');
          }
        } catch (e) {
          debugPrint('❌ [AvatarDisplay] Erreur : $e');
          if (mounted) setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      debugPrint('❌ [AvatarDisplay] Erreur FATALE : $err');
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    // Sécurisation contre le null check
    if (_isTalking != null) _isTalking!.value = widget.state == AvatarState.talking;
    if (_isThinking != null) _isThinking!.value = widget.state == AvatarState.thinking;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildErrorFallback();
    if (_riveArtboard == null) return _buildLoading();

    return Rive(
      artboard: _riveArtboard!,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));

  Widget _buildErrorFallback() => const Center(child: Icon(Icons.error_outline, color: Colors.redAccent));
}
