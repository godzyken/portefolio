import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  void _loadRive() {
    debugPrint('📥 Tentative de chargement Rive : ${widget.rivAsset}');
    
    rootBundle.load(widget.rivAsset).then(
      (data) async {
        try {
          // ✅ INITIALISATION REQUISE POUR LE WEB
          await RiveFile.initialize();
          
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;

          // On affiche l'artboard dès qu'il est chargé, même sans machine à états
          setState(() => _riveArtboard = artboard);

          // 🤖 DÉTECTION DE LA MACHINE À ÉTATS
          final smName = artboard.stateMachines.any((sm) => sm.name == 'State Machine 1')
              ? 'State Machine 1'
              : (artboard.stateMachines.isNotEmpty ? artboard.stateMachines.first.name : null);

          if (smName != null) {
            var controller = StateMachineController.fromArtboard(artboard, smName);
            if (controller != null) {
              artboard.addController(controller);
              
              for (var input in controller.inputs) {
                if (input is SMIInput<bool>) {
                  final name = input.name.toLowerCase();
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                }
              }
              _controller = controller;
              debugPrint('✅ Avatar Rive : Machine "$smName" activée');
            }
          } else {
            debugPrint('⚠️ Avatar Rive : Aucune State Machine trouvée dans le fichier');
          }
          
          _updateState();
        } catch (e) {
          debugPrint('❌ Erreur interprétation Rive : $e');
        }
      },
    ).catchError((err) {
      debugPrint('❌ Fichier introuvable ou erreur réseau : $err');
    });
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    _isTalking?.value = widget.state == AvatarState.talking;
    _isThinking?.value = widget.state == AvatarState.thinking;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pour l'instant, on ignore les inputs inutilisés pour éviter les warnings
    // tant que Rive n'est pas pleinement actif avec un asset.
    final _ = [_isTalking, _isThinking]; 

    if (_riveArtboard == null) {
      return _buildFallback();
    }

    return Rive(artboard: _riveArtboard!);
  }

  Widget _buildFallback() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorHelpers.cyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ColorHelpers.cyan.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _getIconForState(),
              size: 100,
              color: ColorHelpers.cyan,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2.seconds, color: ColorHelpers.cyan.withValues(alpha: 0.1))
              .shake(hz: 2, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          Text(
            _getTextForState(),
            style: const TextStyle(
              color: ColorHelpers.cyan,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForState() {
    switch (widget.state) {
      case AvatarState.idle:
        return Icons.face_rounded;
      case AvatarState.talking:
        return Icons.record_voice_over_rounded;
      case AvatarState.thinking:
        return Icons.psychology_rounded;
    }
  }

  String _getTextForState() {
    switch (widget.state) {
      case AvatarState.idle:
        return "SYSTÈME PRÊT";
      case AvatarState.talking:
        return "TRANSMISSION...";
      case AvatarState.thinking:
        return "ANALYSE EN COURS...";
    }
  }
}
