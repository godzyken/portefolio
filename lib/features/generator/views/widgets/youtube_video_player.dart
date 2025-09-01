import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';

class YoutubeVideoPlayerIframe extends ConsumerStatefulWidget {
  final String videoUrl;
  final String cardId;

  const YoutubeVideoPlayerIframe({
    super.key,
    required this.videoUrl,
    required this.cardId,
  });

  @override
  ConsumerState<YoutubeVideoPlayerIframe> createState() =>
      _YoutubeVideoPlayerIframeState();
}

class _YoutubeVideoPlayerIframeState
    extends ConsumerState<YoutubeVideoPlayerIframe> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId =
        YoutubePlayerController.convertUrlToId(widget.videoUrl) ?? '';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        playsInline: true,
        mute: true,
        showControls: true,
        showFullscreenButton: true,
        loop: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant YoutubeVideoPlayerIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    final playingId = ref.read(playingVideoProvider);
    _updatePlayback(playingId);
  }

  void _updatePlayback(String? playingId) {
    if (playingId == widget.cardId) {
      _controller.playVideo();
    } else {
      _controller.pauseVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playingId = ref.watch(playingVideoProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePlayback(playingId);
    });

    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: YoutubePlayer(
        aspectRatio: 16 / 9,
        controller: _controller,
        key: ValueKey(playingId),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
