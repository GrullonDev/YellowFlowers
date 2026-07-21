import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/auth/auth_service.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class SpecialMessagesBloc extends BaseModel {
  SpecialMessagesBloc();

  final TextEditingController controller = TextEditingController();

  final FlutterTts _tts = FlutterTts();

  static const _kLocalCacheKey = 'special_user_messages';
  static const Duration _syncTimeout = Duration(seconds: 8);

  MessageCategory selected = MessageCategory.love;
  String name = '';

  /// Small built-in seed list — always present, never persisted/synced.
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

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  CollectionReference<Map<String, dynamic>>? get _remoteCollection {
    final uid = di.sl<AuthService>().uid;
    if (uid == null) return null;
    // Same named Firestore database ("amarillas") that FirebaseMusicService
    // already uses — the project does not use the default `(default)`
    // database, so FirebaseFirestore.instance would silently point at an
    // empty/likely-unprovisioned database.
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'amarillas',
    ).collection('users').doc(uid).collection('special_messages');
  }

  Future<void> init() async {
    await _loadUserMessagesFromCache();
    await _loadFavorites();
    // Cache renders instantly; Firestore refresh happens after so a slow
    // or absent connection never blocks the first frame of content.
    unawaited(_syncUserMessagesFromRemote());
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
    final msg = SpecialMessage(
      text: withEmoji,
      category: selected,
      isUserComposed: true,
    );
    _messages.insert(0, msg);
    notifyListeners();
    // Optimistic UI: the message is already visible; persistence happens
    // in the background and never blocks or reverts the insert on
    // failure (it will simply retry on the next app open via cache).
    unawaited(_persistNewMessage(msg));
  }

  void removeAt(int index) {
    if (index < 0 || index >= _messages.length) return;
    final removed = _messages.removeAt(index);
    notifyListeners();
    if (removed.isUserComposed) {
      unawaited(_deleteUserMessage(removed));
    }
  }

  void removeMessage(SpecialMessage msg) {
    _messages.removeWhere((m) =>
        m.text == msg.text &&
        m.category == msg.category &&
        m.createdAt.millisecondsSinceEpoch ==
            msg.createdAt.millisecondsSinceEpoch);
    notifyListeners();
    if (msg.isUserComposed) {
      unawaited(_deleteUserMessage(msg));
    }
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
    if (updated.isUserComposed) {
      // Keep the favorite flag in sync across devices for messages the
      // user wrote themselves.
      unawaited(_persistNewMessage(updated));
    }
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

  List<SpecialMessage> get _userComposedMessages =>
      _messages.where((m) => m.isUserComposed).toList();

  /// Instant local restore so user-composed messages survive an app
  /// restart even fully offline — this is the bug the prior audit
  /// flagged (messages vanishing on hot restart/cold boot).
  Future<void> _loadUserMessagesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalCacheKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final cached = decoded
          .map((e) => SpecialMessage.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _messages.insertAll(0, cached);
      notifyListeners();
    } catch (_) {
      // Corrupt/missing cache: fall back to whatever Firestore sync
      // brings later, or just the seed messages.
    }
  }

  Future<void> _saveUserMessagesLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _userComposedMessages.map((m) => m.toJson()).toList();
      await prefs.setString(_kLocalCacheKey, jsonEncode(data));
    } catch (_) {}
  }

  /// Pulls the authoritative list from Firestore (if signed in and
  /// reachable) and reconciles it with what's on screen. Never blocks
  /// UI — called fire-and-forget from init().
  Future<void> _syncUserMessagesFromRemote() async {
    final collection = _remoteCollection;
    if (collection == null) return; // not signed in yet; stay local-only
    _isSyncing = true;
    notifyListeners();
    try {
      final snapshot = await collection
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get()
          .timeout(_syncTimeout);
      final remote = snapshot.docs
          .map((d) => SpecialMessage.fromJson(d.data()))
          .toList();

      // Merge: remote is the source of truth for anything it has; keep
      // any purely-local message that hasn't made it to Firestore yet
      // (e.g. it was added while offline) so nothing is silently lost.
      final remoteIds = remote.map((m) => m.syncId).toSet();
      final localOnly =
          _userComposedMessages.where((m) => !remoteIds.contains(m.syncId));
      final merged = [...remote, ...localOnly]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _messages
        ..removeWhere((m) => m.isUserComposed)
        ..insertAll(0, merged);
      await _saveUserMessagesLocalCache();

      // Re-upload anything that was local-only so it reaches Firestore.
      for (final m in localOnly) {
        unawaited(_persistNewMessage(m));
      }
    } catch (_) {
      // Offline or Firestore unreachable — the local cache already
      // loaded above is what the user sees; nothing more to do.
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _persistNewMessage(SpecialMessage msg) async {
    await _saveUserMessagesLocalCache();
    final collection = _remoteCollection;
    if (collection == null) return;
    try {
      await collection
          .doc(msg.syncId)
          .set(msg.toJson())
          .timeout(_syncTimeout);
    } catch (_) {
      // Stays in the local cache; _syncUserMessagesFromRemote will
      // retry the upload on a future app open once connectivity returns.
    }
  }

  Future<void> _deleteUserMessage(SpecialMessage msg) async {
    await _saveUserMessagesLocalCache();
    final collection = _remoteCollection;
    if (collection == null) return;
    try {
      await collection.doc(msg.syncId).delete().timeout(_syncTimeout);
    } catch (_) {
      // Best-effort: if this fails the doc may reappear on next sync,
      // which is preferable to silently losing local deletions forever.
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
