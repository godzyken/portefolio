/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/provider/providers.dart';

final youtubeControllerProvider = NotifierProvider<YoutubeControllerNotifier,
    Map<String, YoutubePlayerController>>(YoutubeControllerNotifier.new);

class YoutubeControllerNotifier
    extends Notifier<Map<String, YoutubePlayerController>> {
  @override
  Map<String, YoutubePlayerController> build() {
    return {};
  }

  void registerController(String id, YoutubePlayerController controller) {
    state = {...state, id: controller};
  }

  void unregisterController(String id) {
    final controller = state[id];
    if (controller != null) {
      controller.close();
    }
    final newState = {...state};
    newState.remove(id);
    state = newState;
  }

  void play(String id, WidgetRef ref) {
    state.forEach((key, controller) {
      if (key == id) {
        controller.playVideo();
        ref.read(playingVideoProvider.notifier).state = id;
      } else {
        controller.pauseVideo();
      }
    });
  }

  void pause(String id) {
    state[id]?.pauseVideo();
    // si c'était la vidéo en cours, reset playing
  }
}

final youtubePlayerControllerProvider =
    Provider.family<YoutubePlayerController, String>((ref, videoUrl) {
  final videoId = YoutubePlayerController.convertUrlToId(videoUrl) ?? '';
  final controller = YoutubePlayerController.fromVideoId(
    videoId: videoId,
    autoPlay: false,
    params: const YoutubePlayerParams(
      playsInline: true,
      mute: false,
      showControls: true,
      showFullscreenButton: true,
      loop: false,
      enableJavaScript: true,
    ),
  );

  ref.onDispose(() => controller.close());

  return controller;
});
*/
