import 'dart:developer' as developer;

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
    rootBundle.load(widget.rivAsset).then(
          (data) async {
        try {
          await RiveFile.initialize();
          final file = RiveFile.import(data);

          Artboard? target;
          String? smName;

          // On cherche l'artboard qui contient réellement une state
          // machine exploitable — on exclut explicitement les écrans
          // utilitaires (ex: "soldier selection") qui matcheraient sinon
          // en premier par simple sous-chaîne.
          for (var ab in file.artboards) {
            final abName = ab.name.toLowerCase();
            if (abName.contains('selection') || abName.contains('menu')) {
              continue;
            }
            if (!(abName.contains('soldier') || abName.contains('merc'))) {
              continue;
            }
            for (var sm in ab.stateMachines) {
              final smNameLower = sm.name.toLowerCase();
              if (smNameLower.contains('mercenaries') ||
                  smNameLower.contains('state')) {
                target = ab.instance();
                smName = sm.name;
                break;
              }
            }
            if (target != null) break;
          }

          // Fallback : premier artboard non-"selection" qui a au moins
          // une state machine, sinon l'artboard principal du fichier.
          if (target == null) {
            for (var ab in file.artboards) {
              if (ab.name.toLowerCase().contains('selection')) continue;
              if (ab.stateMachines.isNotEmpty) {
                target = ab.instance();
                smName = ab.stateMachines.first.name;
                break;
              }
            }
          }
          target ??= file.mainArtboard.instance();
          
          if (smName == null && target.stateMachines.isNotEmpty) {
            smName = target.stateMachines.first.name;
          }

          developer.log(
            '🎯 Artboard retenu: "${target.name}" — state machine: '
                '${smName ?? "aucune"}',
            name: 'AvatarDisplay',
          );

          if (smName != null) {
            final controller = StateMachineController.fromArtboard(target, smName);
            if (controller != null) {
              target.addController(controller);
              for (var input in controller.inputs) {
                final name = input.name.toLowerCase();
                if (input is SMIInput<bool>) {
                  if (name.contains('talk')) _isTalking = input;
                  if (name.contains('think')) _isThinking = input;
                }
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
          if (mounted) setState(() => _hasError = true);
        }
      },
    ).catchError((err) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void didUpdateWidget(AvatarDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    final talk = _isTalking;
    final think = _isThinking;
    if (talk != null) talk.value = widget.state == AvatarState.talking;
    if (think != null) think.value = widget.state == AvatarState.thinking;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _riveArtboard;
    if (_hasError) return const Center(child: Icon(Icons.error_outline, color: Colors.redAccent));
    if (artboard == null) return const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan));

    return Rive(
      artboard: artboard,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }
}