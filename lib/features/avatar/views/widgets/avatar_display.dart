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
          
          // On cherche spécifiquement "soldier selection" ou celui qui a la machine
          for (final artboard in file.artboards) {
            if (artboard.name == 'soldier selection' || 
                artboard.stateMachines.any((sm) => sm.name == 'Two mercenaries')) {
              targetArtboard = artboard.instance();
              debugPrint('🎯 [AvatarDisplay] Artboard utilisé : ${artboard.name}');
              break;
            }
          }

          targetArtboard ??= file.mainArtboard.instance();

          final smName = targetArtboard.stateMachines.any((sm) => sm.name == 'Two mercenaries')
              ? 'Two mercenaries'
              : (targetArtboard.stateMachines.isNotEmpty ? targetArtboard.stateMachines.first.name : null);

          if (smName != null) {
            final controller = StateMachineController.fromArtboard(targetArtboard, smName);
            if (controller != null) {
              targetArtboard.addController(controller);
              
              // 🔍 SCAN COMPLET DES INPUTS POUR DEBUG
              for (var input in controller.inputs) {
                debugPrint('💡 [AvatarDisplay] Input trouvé : ${input.name} (${input.runtimeType})');
                
                final name = input.name.toLowerCase();
                if (input is SMIInput<bool>) {
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                  
                  // 🔥 AUTO-ACTIVER : Si c'est un sélecteur, on l'active par défaut
                  if (name.contains('select') || name.contains('show')) {
                    input.value = true;
                  }
                }
                if (input is SMIInput<double> || input is SMIInput<int>) {
                   // Si c'est un index (0 ou 1), on s'assure qu'il n'est pas à une valeur "vide"
                   // (Souvent 0 ou 1 pour choisir entre les deux mercenaires)
                }
              }
              _controller = controller;
            }
          }

          if (mounted) {
            setState(() {
              _riveArtboard = targetArtboard;
              _hasError = false;
            });
            _updateState();
          }
        } catch (e) {
          debugPrint('❌ [AvatarDisplay] Erreur : $e');
          setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      debugPrint('❌ [AvatarDisplay] Erreur : $err');
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

    return Container(
      color: Colors.white.withValues(alpha: 0.02), // Zone de rendu visible pour debug
      child: Rive(
        artboard: _riveArtboard!,
        fit: BoxFit.fitHeight, // ✅ On privilégie la hauteur pour voir le corps entier
        alignment: Alignment.bottomCenter, // ✅ On ancre au sol
      ),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));

  Widget _buildErrorFallback() => const Center(child: Icon(Icons.error_outline, color: Colors.redAccent));
}
