import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';
import '../../controllers/providers/youtube_player_controller_provider.dart';

class YoutubeVideoPlayerIframe extends ConsumerWidget {
  final String videoUrl;
  final String cardId;

  const YoutubeVideoPlayerIframe({
    super.key,
    required this.videoUrl,
    required this.cardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(youtubePlayerControllerProvider(videoUrl));
    final playingId = ref.watch(playingVideoProvider);

    // Play/pause automatique via provider
    if (playingId == cardId) {
      controller.playVideo();
    } else {
      controller.pauseVideo();
    }

    return GestureDetector(
      onTap: () {
        toggle(ref, playingId);
      },
      child: YoutubePlayerControllerProvider(
        controller: controller,
        child: YoutubePlayer(
          aspectRatio: 16 / 9,
          controller: controller,
          key: ValueKey(cardId),
        ),
      ),
    );
  }

  void toggle(WidgetRef ref, String? playingId) {
    final notifier = ref.read(playingVideoProvider.notifier);
    if (playingId == cardId) {
      notifier.stop();
    } else {
      notifier.play(cardId);
    }
  }
}
