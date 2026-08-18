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
    debugPrint('📥 [AvatarDisplay] Tentative de chargement : ${widget.rivAsset}');
    
    rootBundle.load(widget.rivAsset).then(
      (data) async {
        try {
          await RiveFile.initialize();
          final file = RiveFile.import(data);
          
          // 🤖 RECHERCHE INTELLIGENTE DE L'ARTBOARD
          Artboard? targetArtboard;
          
          // On liste tous les artboards pour trouver celui qui a la machine 'Two mercenaries'
          for (final artboard in file.artboards) {
            if (artboard.stateMachines.any((sm) => sm.name == 'Two mercenaries' || sm.name == 'State Machine 1')) {
              targetArtboard = artboard.instance();
              debugPrint('🎯 [AvatarDisplay] Artboard détecté : ${artboard.name}');
              break;
            }
          }

          // Si on n'a rien trouvé, on prend le mainArtboard
          targetArtboard ??= file.mainArtboard.instance();

          // ⚙️ CONFIGURATION DU CONTROLLER
          final smName = targetArtboard.stateMachines.any((sm) => sm.name == 'Two mercenaries')
              ? 'Two mercenaries'
              : (targetArtboard.stateMachines.isNotEmpty ? targetArtboard.stateMachines.first.name : null);

          StateMachineController? controller;
          if (smName != null) {
            controller = StateMachineController.fromArtboard(targetArtboard, smName);
            if (controller != null) {
              targetArtboard.addController(controller);
              for (var input in controller.inputs) {
                if (input is SMIInput<bool>) {
                  final name = input.name.toLowerCase();
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                }
              }
            }
          }

          if (mounted) {
            setState(() {
              _riveArtboard = targetArtboard;
              _controller = controller;
              _hasError = false;
            });
            _updateState();
            debugPrint('✅ [AvatarDisplay] Rendu prêt sur Artboard: ${targetArtboard?.name}');
          }
        } catch (e) {
          debugPrint('❌ [AvatarDisplay] Erreur interprétation : $e');
          setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      debugPrint('❌ [AvatarDisplay] Erreur accès fichier : $err');
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
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
      fit: BoxFit.cover, // ✅ Remplit l'écran pour l'effet théâtre
      alignment: Alignment.center,
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));
  }

  Widget _buildErrorFallback() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          Text("Erreur d'affichage", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
