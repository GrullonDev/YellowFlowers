import 'dart:async';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/tts/tts_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class SpecialMessagesBloc extends BaseModel {
  SpecialMessagesBloc({
    TtsService? ttsService,
    bool Function()? isMusicPlaying,
    Future<void> Function()? pauseMusic,
    Future<void> Function()? resumeMusic,
    Duration speechTimeout = const Duration(seconds: 30),
  })  : _ttsService = ttsService ?? sl<TtsService>(),
        _isMusicPlaying = isMusicPlaying ?? (() => sl<AudioPlayer>().playing),
        _pauseMusic = pauseMusic ?? (() => sl<AudioPlayer>().pause()),
        _resumeMusic = resumeMusic ?? (() => sl<AudioPlayer>().play()),
        _speechTimeout = speechTimeout;

  final TextEditingController controller = TextEditingController();

  final TtsService _ttsService;
  final bool Function() _isMusicPlaying;
  final Future<void> Function() _pauseMusic;
  final Future<void> Function() _resumeMusic;
  final Duration _speechTimeout;

  /// The currently in-flight [_speak] call, if any — lets a new call
  /// interrupt and wait for the previous one to fully pause/resume before
  /// starting its own cycle, so two overlapping calls can never interleave
  /// their pause/resume bookkeeping.
  Future<void>? _activeSpeech;

  MessageCategory selected = MessageCategory.love;
  String name = '';

  final List<SpecialMessage> _messages = [
    SpecialMessage(
        text: 'Eres mi razón para sonreír hoy', category: MessageCategory.love),
    SpecialMessage(
        text: 'Tu luz hace más bonito cualquier momento',
        category: MessageCategory.friendship),
    SpecialMessage(
        text: 'Confía en ti. Puedes con todo',
        category: MessageCategory.selfEsteem),
  ];

  final List<SpecialMessage> _favorites = [];
  List<SpecialMessage> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    await _loadFavorites();
  }

  List<SpecialMessage> get messages => List.unmodifiable(_messages);

  void setCategory(MessageCategory c) {
    selected = c;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void addMessage(String text) {
    if (text.trim().isEmpty) return;
    final withEmoji = '${_categoryEmoji(selected)} ${_applyName(text.trim())}';
    _messages.insert(0, SpecialMessage(text: withEmoji, category: selected));
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _messages.length) return;
    _messages.removeAt(index);
    notifyListeners();
  }

  void removeMessage(SpecialMessage msg) {
    _messages.removeWhere((m) =>
        m.text == msg.text &&
        m.category == msg.category &&
        m.createdAt.millisecondsSinceEpoch ==
            msg.createdAt.millisecondsSinceEpoch);
    notifyListeners();
  }

  void toggleFavorite(int index) {
    if (index < 0 || index >= _messages.length) return;
    final m = _messages[index];
    final updated = m.copyWith(isFavorite: !m.isFavorite);
    _messages[index] = updated;
    if (updated.isFavorite) {
      _favorites.insert(0, updated);
    } else {
      _favorites
          .removeWhere((e) => e.text == m.text && e.category == m.category);
    }
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _favorites
          .map((m) =>
              '${m.category.name}|${m.text}|${m.createdAt.millisecondsSinceEpoch}')
          .toList();
      await prefs.setStringList('special_favorites', data);
    } catch (_) {
      // Puede fallar en hot reload si el canal nativo aún no está listo.
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('special_favorites') ?? const [];
      _favorites
        ..clear()
        ..addAll(list.map((row) {
          final parts = row.split('|');
          if (parts.length < 3) {
            return SpecialMessage(text: row, category: MessageCategory.love);
          }
          final cat = MessageCategory.values.firstWhere(
            (c) => c.name == parts[0],
            orElse: () => MessageCategory.love,
          );
          final ts =
              int.tryParse(parts[2]) ?? DateTime.now().millisecondsSinceEpoch;
          return SpecialMessage(
            text: parts[1],
            category: cat,
            createdAt: DateTime.fromMillisecondsSinceEpoch(ts),
            isFavorite: true,
          );
        }));
      // Reflejar estado favorito en la lista principal
      for (var i = 0; i < _messages.length; i++) {
        final m = _messages[i];
        final fav =
            _favorites.any((f) => f.text == m.text && f.category == m.category);
        _messages[i] = m.copyWith(isFavorite: fav);
      }
      notifyListeners();
    } catch (_) {
      // Puede fallar en hot reload; al reiniciar, cargará bien.
    }
  }

  Future<void> speak(int index) async {
    if (index < 0 || index >= _messages.length) return;
    await _speak(_messages[index].text);
  }

  Future<void> speakMessage(SpecialMessage msg) async {
    await _speak(msg.text);
  }

  /// Ducks whatever music is already playing for the duration of the
  /// narration, then resumes it once speech actually finishes. If another
  /// call is already in flight, it's interrupted and fully unwound first
  /// so two calls' pause/resume bookkeeping can never interleave.
  Future<void> _speak(String text) async {
    final inFlight = _activeSpeech;
    if (inFlight != null) {
      await _ttsService.stop();
      await inFlight;
    }

    final completer = Completer<void>();
    _activeSpeech = completer.future;
    final wasPlaying = _isMusicPlaying();
    try {
      if (wasPlaying) {
        await _pauseMusic();
      }
      await _speakAndWaitForEnd(text);
    } catch (_) {
    } finally {
      if (wasPlaying) {
        await _resumeMusic();
      }
      completer.complete();
      if (identical(_activeSpeech, completer.future)) {
        _activeSpeech = null;
      }
    }
  }

  /// Registers the completion listener *before* asking [TtsService] to
  /// speak, then waits for a full speaking -> not-speaking cycle (bounded
  /// by [_speechTimeout]). This matters because flutter_tts's speak()
  /// Future resolves once the native call is dispatched, not once speech
  /// actually starts — checking state only *after* that Future resolves
  /// can miss a delayed onStart callback entirely.
  Future<void> _speakAndWaitForEnd(String text) async {
    final completer = Completer<void>();
    var started = _ttsService.state == TtsState.speaking;
    void listener() {
      if (_ttsService.state == TtsState.speaking) {
        started = true;
      } else if (started && !completer.isCompleted) {
        completer.complete();
      }
    }

    _ttsService.stateNotifier.addListener(listener);
    try {
      await _ttsService.speak(text);
      await completer.future.timeout(_speechTimeout);
    } finally {
      _ttsService.stateNotifier.removeListener(listener);
    }
  }

  String _categoryEmoji(MessageCategory c) => c.emoji;
  String _applyName(String text) =>
      name.isEmpty ? text : text.replaceAll('{nombre}', name);

  @override
  void dispose() {
    controller.dispose();
    try {
      // sl<TtsService>() is a shared singleton (unless a fake was injected
      // for a test) — stop any speech this bloc started, but never
      // dispose() it, other screens may still rely on it.
      _ttsService.stop();
    } catch (_) {}
    super.dispose();
  }
}
