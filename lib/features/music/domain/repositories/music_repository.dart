import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import '../entities/song_entity.dart';

abstract class MusicRepository {
  Future<Result<List<SongEntity>>> getSongs(String genre);
  Future<Result<List<SongEntity>>> getSongsByMood(Mood mood);
  Future<Result<SongEntity?>> getDailyRecommendation(Mood mood);
  Future<Result<void>> playSong(SongEntity song);
  Future<Result<void>> pauseSong();
  Future<Result<void>> stopSong();
  Future<Result<Duration>> getCurrentPosition();
  Future<Result<Stream<Duration>>> getPositionStream();
}
