import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends Notifier<bool> {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  @override
  bool build() {
    _safeInit();
    return false;
  }

  Future<void> _safeInit() async {
    if (_initialized) return;

    try {
      final dynamic langResult = await _tts.getLanguages;
      if (langResult != null) {
        await _tts.setLanguage("fr-FR");
      }

      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() => state = true);
      _tts.setCompletionHandler(() => state = false);
      _tts.setErrorHandler((msg) {
        developer.log("TTS Error: $msg", name: 'VoiceService');
        state = false;
      });

      _initialized = true;
    } catch (e) {
      developer.log("TTS Safe Init failed: $e", name: 'VoiceService');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      final cleanText = text.replaceAll(RegExp(r'[*#_]'), '');
      await _tts.speak(cleanText);
    } catch (e) {
      state = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } finally {
      state = false;
    }
  }
}

final voiceServiceProvider = NotifierProvider<VoiceService, bool>(
  VoiceService.new,
);
