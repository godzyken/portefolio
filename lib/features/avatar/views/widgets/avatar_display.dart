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
    debugPrint('📥 [AvatarDisplay] Chargement : ${widget.rivAsset}');
    
    rootBundle.load(widget.rivAsset).then(
      (data) async {
        try {
          await RiveFile.initialize();
          final file = RiveFile.import(data);
          
          // 🔍 DEBUG : Lister tous les Artboards disponibles
          for (var ab in file.artboards) {
            debugPrint('🗂️ Artboard disponible dans le fichier : ${ab.name}');
          }

          // On cherche l'Artboard le plus probable
          Artboard? target;
          try {
            // Tentative 1 : chercher un artboard qui contient "soldier" ou "mercenary"
            target = file.artboards.firstWhere(
              (ab) => ab.name.toLowerCase().contains('soldier') || ab.name.toLowerCase().contains('merc'),
            ).instance();
          } catch (_) {
            // Tentative 2 : prendre le mainArtboard
            target = file.mainArtboard.instance();
          }

          debugPrint('🎯 [AvatarDisplay] Artboard sélectionné : ${target.name}');

          // On cherche une machine à états
          if (target.stateMachines.isNotEmpty) {
            final sm = target.stateMachines.firstWhere(
              (s) => s.name.toLowerCase().contains('mercenaries') || s.name.toLowerCase().contains('state'),
              orElse: () => target!.stateMachines.first,
            );

            final controller = StateMachineController.fromArtboard(target, sm.name);
            if (controller != null) {
              target.addController(controller);
              for (var input in controller.inputs) {
                final name = input.name.toLowerCase();
                if (input is SMIInput<bool>) {
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                }
                // 🔥 On essaie de forcer l'affichage
                if (name.contains('state') && input is SMIInput<double>) {
                  input.value = 1.0; 
                }
              }
              _controller = controller;
            }
          }

          if (mounted) {
            setState(() {
              _riveArtboard = target;
              _hasError = false;
            });
            _updateState();
          }
        } catch (e) {
          debugPrint('❌ [AvatarDisplay] Erreur build : $e');
          if (mounted) setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      debugPrint('❌ [AvatarDisplay] Erreur Asset : $err');
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
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));

  Widget _buildErrorFallback() => const Center(child: Icon(Icons.error_outline, color: Colors.redAccent));
}
