import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

abstract class MusicLocalDataSource {
  Future<void> cacheSongs(String key, List<Song> songs);
  Future<List<Song>> getCachedSongs(String key);
  Future<void> cacheRecommendation(Mood mood, Song song);
  Future<Song?> getCachedRecommendation(Mood mood);
}

class MusicLocalDataSourceImpl implements MusicLocalDataSource {
  MusicLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  static const _prefix = 'cached_music_';

  @override
  Future<void> cacheSongs(String key, List<Song> songs) async {
    final jsonList = songs.map((s) => s.toJson()).toList();
    await _sharedPreferences.setString('$_prefix$key', jsonEncode(jsonList));
  }

  @override
  Future<List<Song>> getCachedSongs(String key) async {
    final jsonStr = _sharedPreferences.getString('$_prefix$key');
    if (jsonStr == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((j) => Song.fromJson(j)).toList();
  }

  @override
  Future<void> cacheRecommendation(Mood mood, Song song) async {
    await _sharedPreferences.setString(
      '${_prefix}recommendation_${mood.name}',
      jsonEncode(song.toJson()),
    );
  }

  @override
  Future<Song?> getCachedRecommendation(Mood mood) async {
    final jsonStr =
        _sharedPreferences.getString('${_prefix}recommendation_${mood.name}');
    if (jsonStr == null) return null;
    return Song.fromJson(jsonDecode(jsonStr));
  }
}
