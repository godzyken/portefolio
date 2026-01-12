import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';

class YoutubeVideoPlayerIframe extends ConsumerStatefulWidget {
  final String youtubeVideoId;
  final String cardId;

  const YoutubeVideoPlayerIframe({
    super.key,
    required this.youtubeVideoId,
    required this.cardId,
  });

  @override
  ConsumerState<YoutubeVideoPlayerIframe> createState() =>
      _YoutubeVideoPlayerIframeState();
}

class _YoutubeVideoPlayerIframeState
    extends ConsumerState<YoutubeVideoPlayerIframe> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (!mounted) return;

      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.youtubeVideoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
          pointerEvents: PointerEvents.auto,
        ),
      );

      // ✅ Attendre que le controller soit prêt
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ✅ Lancer la vidéo seulement si le widget est monté et visible
      if (!kIsWeb && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(playingVideoProvider.notifier).play(widget.cardId);
            _controller?.playVideo();
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(playingVideoProvider, (previous, next) {
      if (next == widget.cardId) {
        _controller?.playVideo();
      } else {
        _controller?.pauseVideo();
      }
    });

    final isVideoVisible = ref.watch(globalVideoVisibilityProvider);
    final isPlaying =
        ref.watch(playingVideoProvider.select((id) => id == widget.cardId));

    if (!isVideoVisible) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Chargement de la vidéo...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError || _controller == null) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger la vidéo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initializePlayer();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb) {
      return Stack(
        alignment: Alignment.center,
        children: [
          YoutubePlayer(
            controller: _controller!,
            aspectRatio: 16 / 9,
            key: ValueKey(widget.youtubeVideoId),
          ),
          // Overlay cliquable seulement si la vidéo n'est pas en lecture
          if (!isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  ref.read(playingVideoProvider.notifier).play(widget.cardId);
                  _controller?.playVideo();
                },
                child: Container(
                  color: Colors.black45,
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return AnimatedOpacity(
        opacity: isVideoVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
            ignoring: !isVideoVisible,
            child: YoutubePlayer(
              controller: _controller!,
              aspectRatio: 16 / 9,
              key: ValueKey(widget.youtubeVideoId),
            )));
  }
}

extension VideoOverlayHelper on BuildContext {
  /// Affiche un Dialog en masquant temporairement les vidéos
  Future<T?> showDialogWithVideoHidden<T>({
    required Widget dialog,
    required WidgetRef ref,
    bool barrierDismissible = true,
  }) async {
    // 1. Cache les vidéos
    ref.read(globalVideoVisibilityProvider.notifier).setFalse();

    // 2. Pause toutes les vidéos
    ref.read(playingVideoProvider.notifier).stop();

    try {
      // 3. Affiche le dialog
      final result = await showDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (context) => dialog,
      );
      return result;
    } finally {
      // 4. Réaffiche les vidéos après fermeture
      ref.read(globalVideoVisibilityProvider.notifier).setTrue();
    }
  }

  /// Affiche un BottomSheet en masquant les vidéos
  Future<T?> showBottomSheetWithVideoHidden<T>({
    required Widget bottomSheet,
    required WidgetRef ref,
    bool isScrollControlled = true,
  }) async {
    ref.read(globalVideoVisibilityProvider.notifier).setFalse();
    ref.read(playingVideoProvider.notifier).stop();

    try {
      final result = await showModalBottomSheet<T>(
        context: this,
        isScrollControlled: isScrollControlled,
        builder: (context) => bottomSheet,
      );
      return result;
    } finally {
      ref.read(globalVideoVisibilityProvider.notifier).setTrue();
    }
  }
}
