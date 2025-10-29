import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';

class YoutubeVideoPlayerIframe extends ConsumerStatefulWidget {
  // ✅ 1. Passer en StatefulWidget
  final String youtubeVideoId; // ✅ 2. Accepter un ID, pas une URL
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
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // ✅ 3. Initialiser le contrôleur ici, avec l'ID
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeVideoId,
      autoPlay: false, // On contrôle la lecture via le provider
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.auto,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 4. Utiliser ref.listen pour réagir au changement sans causer de rebuild en boucle
    ref.listen<String?>(playingVideoProvider, (previous, next) {
      if (next == widget.cardId) {
        _controller.playVideo();
      } else {
        _controller.pauseVideo();
      }
    });

    final isVideoVisible = ref.watch(globalVideoVisibilityProvider);

    if (!isVideoVisible) {
      return const SizedBox.shrink();
    }

    return AbsorbPointer(
        absorbing: !isVideoVisible,
        child: GestureDetector(
          onTap: () {
            final notifier = ref.read(playingVideoProvider.notifier);
            if (notifier.isPlaying(widget.cardId)) {
              notifier.stop();
            } else {
              notifier.play(widget.cardId);
            }
          },
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            key: ValueKey(widget.youtubeVideoId),
          ),
        ));
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
    ref.read(globalVideoVisibilityProvider.notifier).hide();

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
      ref.read(globalVideoVisibilityProvider.notifier).show();
    }
  }

  /// Affiche un BottomSheet en masquant les vidéos
  Future<T?> showBottomSheetWithVideoHidden<T>({
    required Widget bottomSheet,
    required WidgetRef ref,
    bool isScrollControlled = true,
  }) async {
    ref.read(globalVideoVisibilityProvider.notifier).hide();
    ref.read(playingVideoProvider.notifier).stop();

    try {
      final result = await showModalBottomSheet<T>(
        context: this,
        isScrollControlled: isScrollControlled,
        builder: (context) => bottomSheet,
      );
      return result;
    } finally {
      ref.read(globalVideoVisibilityProvider.notifier).show();
    }
  }
}
