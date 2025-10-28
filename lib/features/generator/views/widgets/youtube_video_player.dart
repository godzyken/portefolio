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

    return GestureDetector(
      onTap: () {
        final playingId = ref.read(playingVideoProvider);
        final notifier = ref.read(playingVideoProvider.notifier);
        if (playingId == widget.cardId) {
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
    );
  }
}
