import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';

enum AvatarState { idle, talking, thinking }

class AvatarDisplay extends StatefulWidget {
  final AvatarState state;
  final String? rivAsset;

  const AvatarDisplay({
    super.key,
    this.state = AvatarState.idle,
    this.rivAsset,
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
    if (widget.rivAsset != null) {
      _loadRive();
    }
  }

  void _loadRive() {
    // Logique de chargement Rive si on avait un fichier
    // Sera implémentée quand l'asset .riv sera fourni
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

    if (widget.rivAsset == null || _riveArtboard == null) {
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
