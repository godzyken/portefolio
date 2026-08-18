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
    this.rivAsset = 'assets/images/animations/avatar_animate.riv', // ✅ Chemin complet impératif
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
    debugPrint('📥 [AvatarDisplay] Chargement : ${widget.rivAsset}');
    
    rootBundle.load(widget.rivAsset).then(
      (data) async {
        try {
          await RiveFile.initialize();
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;

          // 🤖 DÉTECTION DE LA MACHINE À ÉTATS
          final smName = artboard.stateMachines.any((sm) => sm.name == 'State Machine 1')
              ? 'State Machine 1'
              : (artboard.stateMachines.isNotEmpty ? artboard.stateMachines.first.name : null);

          StateMachineController? controller;
          if (smName != null) {
            controller = StateMachineController.fromArtboard(artboard, smName);
            if (controller != null) {
              artboard.addController(controller);
              for (var input in controller.inputs) {
                if (input is SMIInput<bool>) {
                  final name = input.name.toLowerCase();
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                }
              }
            }
          }

          // ✅ MISE À JOUR DE L'ÉTAT POUR AFFICHAGE
          if (mounted) {
            setState(() {
              _riveArtboard = artboard;
              _controller = controller;
              _hasError = false;
            });
            _updateState();
            debugPrint('✅ [AvatarDisplay] Rendu prêt. Machine: $smName');
          }
        } catch (e) {
          debugPrint('❌ [AvatarDisplay] Erreur interprétation : $e');
          setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      debugPrint('❌ [AvatarDisplay] Erreur réseau/accès : $err');
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
      fit: BoxFit.contain, // ✅ On passe en contain pour être sûr de voir le perso au début
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
          Text("Erreur d'affichage avatar", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    // Gardé par compatibilité mais remplacé par _buildLoading/_buildError
    return const SizedBox.shrink();
  }

  IconData _getIconForState() => Icons.face; // Non utilisé
}
