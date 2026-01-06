import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier qui gère quelle vidéo est actuellement en lecture.
/// Si `state == null` → aucune vidéo ne joue.
/// Si `state == "card123"` → la vidéo avec cet ID est active.
class PlayingVideoNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Joue une vidéo spécifique (et arrête les autres)
  void play(String cardId) => state = cardId;

  /// Stoppe toute lecture
  void stop() => state = null;

  /// Bascule lecture/pause selon la vidéo cliquée
  void toggle(String cardId) {
    if (state == cardId) {
      stop();
    } else {
      play(cardId);
    }
  }

  /// Vérifie si la vidéo donnée est en lecture
  bool isPlaying(String cardId) => state == cardId;
}
