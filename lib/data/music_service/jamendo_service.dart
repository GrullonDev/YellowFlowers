// jamendo_api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:yellow_flowers/features/romantic_music/data/model/song.dart';

class JamendoApiService {
  final String clientId = '5f4b0a1e'; // Reemplaza con tu client ID
  final String baseUrl = 'https://api.jamendo.com/v3.0';

  Future<List<Song>> getTracks(String genre) async {
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$clientId&format=json&limit=10&tags=$genre');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((track) {
        return Song(
          id: track['id'].toString(),
          title: track['name'],
          artist: track['artist_name'],
          audioUrl: track['audio'],
          coverUrl: track['album_image'],
          duration: Duration(seconds: track['duration']),
          genre: genre,
        );
      }).toList();
    } else {
      throw Exception('Failed to load tracks');
    }
  }
}
