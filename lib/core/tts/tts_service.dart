import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

enum TtsState { stopped, speaking, paused, initializing }

class TtsService {
  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _init();
  }

  final FlutterTts _tts;
  final ValueNotifier<TtsState> stateNotifier =
      ValueNotifier(TtsState.initializing);
  TtsState get state => stateNotifier.value;

  Future<void> _init() async {
    try {
      stateNotifier.value = TtsState.initializing;
      // iOS: categoría que permite sonar aunque el teléfono esté en silencio (respectar: playAndRecord si se requiere mic)
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
        );
      }

      await _tts.setLanguage('es-ES');
      // fallback: si no disponible, probar 'es-419' (latam)
      final langs = await _tts.getLanguages;
      if (!langs.contains('es-ES')) {
        if (langs.contains('es-419')) {
          await _tts.setLanguage('es-419');
        } else if (langs.contains('es-MX')) {
          await _tts.setLanguage('es-MX');
        }
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() => stateNotifier.value = TtsState.speaking);
      _tts.setCompletionHandler(() => stateNotifier.value = TtsState.stopped);
      _tts.setCancelHandler(() => stateNotifier.value = TtsState.stopped);
      _tts.setPauseHandler(() => stateNotifier.value = TtsState.paused);
      _tts.setContinueHandler(() => stateNotifier.value = TtsState.speaking);
      _tts.setErrorHandler((msg) {
        stateNotifier.value = TtsState.stopped;
      });
      stateNotifier.value = TtsState.stopped;
    } catch (_) {
      stateNotifier.value = TtsState.stopped;
    }
  }

  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await stop();
    await _tts.speak(trimmed);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } finally {
      stateNotifier.value = TtsState.stopped;
    }
  }

  Future<void> toggle(String text) async {
    if (stateNotifier.value == TtsState.speaking) {
      await stop();
    } else {
      await speak(text);
    }
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
