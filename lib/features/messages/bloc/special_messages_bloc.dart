import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class SpecialMessagesBloc extends BaseModel {
  SpecialMessagesBloc();

  final TextEditingController controller = TextEditingController();

  final FlutterTts _tts = FlutterTts();

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
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.48);
      await _tts.speak(_messages[index].text);
    } catch (_) {}
  }

  Future<void> speakMessage(SpecialMessage msg) async {
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.48);
      await _tts.speak(msg.text);
    } catch (_) {}
  }

  String _categoryEmoji(MessageCategory c) => c.emoji;
  String _applyName(String text) =>
      name.isEmpty ? text : text.replaceAll('{nombre}', name);

  @override
  void dispose() {
    controller.dispose();
    try {
      _tts.stop();
    } catch (_) {}
    super.dispose();
  }
}
