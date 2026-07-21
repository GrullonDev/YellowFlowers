import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

/// Servicio de música basado en Firestore + Firebase Storage.
///
/// Estructura esperada en Firestore:
/// Colección: `songs`
///   Documento por canción con los campos:
///     - title        : String  — nombre de la canción
///     - artist       : String  — nombre del artista
///     - audio_url    : String  — URL de descarga desde Firebase Storage
///     - cover_url    : String  — URL de la imagen de portada
///     - duration     : int     — duración en segundos
///     - genre        : String  — género (ej. "pop", "acoustic")
///     - mood         : String  — uno de: relaxed, romantic, motivated, nostalgic, happy
///     - is_active    : bool    — si la canción está activa/visible
///
/// Para poblar la base de datos usa la consola de Firebase o el script
/// de seed incluido en /scripts/seed_firestore.js
class FirebaseMusicService {
  FirebaseMusicService({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: 'amarillas',
            );

  final FirebaseFirestore _firestore;
  static const String _collection = 'songs';

  /// Bounds every Firestore query so a poor/absent connection surfaces a
  /// clear error (and triggers the local-cache fallback in
  /// MusicRepositoryImpl) instead of leaving the UI spinning indefinitely.
  static const Duration _queryTimeout = Duration(seconds: 8);

  String _moodToString(Mood mood) {
    switch (mood) {
      case Mood.relaxed:
        return 'relaxed';
      case Mood.romantic:
        return 'romantic';
      case Mood.motivated:
        return 'motivated';
      case Mood.nostalgic:
        return 'nostalgic';
      case Mood.happy:
        return 'happy';
    }
  }

  /// Obtiene canciones filtradas por mood. Filtra is_active en cliente
  /// para evitar necesitar índices compuestos en Firestore.
  Future<List<Song>> getSongsByMood(Mood mood, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('mood', isEqualTo: _moodToString(mood))
        .limit(limit + 10) // margen por si algunas están inactivas
        .get()
        .timeout(_queryTimeout);

    return snapshot.docs
        .where((doc) => doc.data()['is_active'] == true)
        .take(limit)
        .map((doc) => Song.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Obtiene canciones por género/etiqueta. Útil para el selector de géneros de la UI.
  Future<List<Song>> getSongsByGenre(String genre, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('genre', isEqualTo: genre)
        .limit(limit + 10)
        .get()
        .timeout(_queryTimeout);

    return snapshot.docs
        .where((doc) => doc.data()['is_active'] == true)
        .take(limit)
        .map((doc) => Song.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Devuelve una canción aleatoria del mood indicado.
  Future<Song?> getRandomSongByMood(Mood mood) async {
    final songs = await getSongsByMood(mood, limit: 50);
    if (songs.isEmpty) return null;
    songs.shuffle();
    return songs.first;
  }

  /// Obtiene todas las canciones activas (útil para fallback genérico).
  Future<List<Song>> getAllSongs({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('is_active', isEqualTo: true)
        .limit(limit)
        .get()
        .timeout(_queryTimeout);

    return snapshot.docs
        .map((doc) => Song.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}
