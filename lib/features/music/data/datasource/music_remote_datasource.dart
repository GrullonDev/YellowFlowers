import 'package:just_audio/just_audio.dart';

import 'package:yellow_flowers/data/music_service/firebase_music_service.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';

abstract class MusicRemoteDataSource {
  Future<List<Song>> getSongs(String genre);
  Future<List<Song>> getSongsByMood(Mood mood);
  Future<Song?> getDailyRecommendation(Mood mood);
  Future<void> playSong(Song song);
  Future<void> pauseSong();
  Future<void> stopSong();
  Future<Duration> getCurrentPosition();
  Future<Stream<Duration>> getPositionStream();
  Future<void> seekTo(Duration position);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  MusicRemoteDataSourceImpl({
    required AudioPlayer audioPlayer,
    required FirebaseMusicService musicService,
  })  : _audioPlayer = audioPlayer,
        _musicService = musicService;

  final AudioPlayer _audioPlayer;
  final FirebaseMusicService _musicService;

  @override
  Future<List<Song>> getSongs(String genre) async {
    return _musicService.getSongsByGenre(genre);
  }

  @override
  Future<List<Song>> getSongsByMood(Mood mood) async {
    return _musicService.getSongsByMood(mood);
  }

  @override
  Future<Song?> getDailyRecommendation(Mood mood) async {
    return _musicService.getRandomSongByMood(mood);
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

  @override
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }
}
