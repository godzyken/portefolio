import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends Notifier<bool> {
  final FlutterTts _tts = FlutterTts();

  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    await _tts.setLanguage("fr-FR");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      state = true;
    });

    _tts.setCompletionHandler(() {
      state = false;
    });

    _tts.setErrorHandler((msg) {
      state = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    final cleanText = text.replaceAll(RegExp(r'[*#_]'), '');
    await _tts.speak(cleanText);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = false;
  }
}

final voiceServiceProvider = NotifierProvider<VoiceService, bool>(
  VoiceService.new,
);
