// jamendo_api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/utils/constants.dart';

class JamendoApiService {
  JamendoApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl = 'https://api.jamendo.com/v3.0';

  String get _clientId {
    if (kJamendoClientId == 'YOUR_JAMENDO_CLIENT_ID_HERE' ||
        kJamendoClientId.trim().isEmpty) {
      throw StateError(
          'Jamendo Client ID not set. Please set kJamendoClientId in utils/constants.dart');
    }
    return kJamendoClientId;
  }

  /// Map a mood to Jamendo tags/genres (list for fuzzy match)
  String _tagsForMood(Mood mood) {
    switch (mood) {
      case Mood.relaxed:
        return 'acoustic,chill,ambient,calm,soothing';
      case Mood.romantic:
        return 'ballad,piano,softpop,romantic,love';
      case Mood.motivated:
        return 'pop,energetic,electronic,dance,workout';
      case Mood.nostalgic:
        return 'retro,classics,softrock,oldies,vintage';
      case Mood.happy:
        return 'happy,feelgood,upbeat,indiepop,summer';
    }
  }

  Future<List<Song>> getTracks(String genreOrMoodTag, {int limit = 20}) async {
    // Jamendo often yields better results with fuzzytags and '+' separated terms
    final fuzzy = genreOrMoodTag.replaceAll(',', '+');
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&fuzzytags=$fuzzy&order=popularity_total&audioformat=mp31&include=musicinfo+stats');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      return results.map(_mapTrack).toList();
    } else {
      throw Exception('Failed to load tracks (${response.statusCode})');
    }
  }

  Future<List<Song>> getTracksByMood(Mood mood, {int limit = 20}) {
    return getTracks(_tagsForMood(mood), limit: limit);
  }

  Future<Song?> randomTrackByMood(Mood mood) async {
    final fuzzy = _tagsForMood(mood).replaceAll(',', '+');
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$_clientId&format=json&limit=1&fuzzytags=$fuzzy&order=random&audioformat=mp31');
    final response = await _client.get(url);
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    if (results.isEmpty) return null;
    return _mapTrack(results.first);
  }

  Future<Song?> getTrackById(String id) async {
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$_clientId&format=json&id=$id&audioformat=mp31');
    final response = await _client.get(url);
    if (response.statusCode != 200) return null;
    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    if (results.isEmpty) return null;
    return _mapTrack(results.first);
  }

  Song _mapTrack(Map<String, dynamic> track) {
    return Song(
      id: track['id'].toString(),
      title: track['name'] ?? track['title'] ?? 'Unknown',
      artist: track['artist_name'] ?? 'Unknown',
      audioUrl: track['audio'] ?? track['audio_url'] ?? '',
      coverUrl: track['album_image'] ?? track['image'] ?? '',
      duration: Duration(seconds: (track['duration'] as num?)?.toInt() ?? 0),
      genre: (track['musicinfo']?['tags']?['genres'] as List?)?.join(',') ??
          (track['genre']?.toString() ?? ''),
    );
  }
}
