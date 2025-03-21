import 'package:just_audio/just_audio.dart';

import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import 'package:yellow_flowers/features/romantic_music/data/model/song.dart';

abstract class MusicRemoteDataSource {
  Future<List<Song>> getSongs(String genre);
  Future<void> playSong(Song song);
  Future<void> pauseSong();
  Future<void> stopSong();
  Future<Duration> getCurrentPosition();
  Future<Stream<Duration>> getPositionStream();
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final AudioPlayer _audioPlayer;
  final JamendoApiService _apiService;

  MusicRemoteDataSourceImpl({
    required AudioPlayer audioPlayer,
    required JamendoApiService apiService,
  })  : _audioPlayer = audioPlayer,
        _apiService = apiService;

  @override
  Future<List<Song>> getSongs(String genre) async {
    return _apiService.getTracks(genre);
  }

  @override
  Future<void> playSong(Song song) async {
    await _audioPlayer.setUrl(song.audioUrl);
    await _audioPlayer.play();
  }

  @override
  Future<void> pauseSong() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stopSong() async {
    await _audioPlayer.stop();
  }

  @override
  Future<Duration> getCurrentPosition() async {
    return _audioPlayer.position;
  }

  @override
  Future<Stream<Duration>> getPositionStream() async {
    return _audioPlayer.positionStream;
  }
}
