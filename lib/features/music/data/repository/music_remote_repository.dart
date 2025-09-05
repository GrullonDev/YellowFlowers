import 'package:yellow_flowers/features/music/data/datasource/music_remote_datasource.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';

abstract class MusicRemoteRepository {
  Future<List<Song>> getSongs(String genre);
  Future<void> playSong(Song song);
  Future<void> pauseSong();
  Future<void> stopSong();
  Future<Duration> getCurrentPosition();
  Future<Stream<Duration>> getPositionStream();
}

class MusicRemoteRepositoryImpl implements MusicRemoteRepository {

  MusicRemoteRepositoryImpl({required MusicRemoteDataSource dataSource})
      : _dataSource = dataSource;
  final MusicRemoteDataSource _dataSource;

  @override
  Future<List<Song>> getSongs(String genre) async {
    return _dataSource.getSongs(genre);
  }

  @override
  Future<void> playSong(Song song) async {
    await _dataSource.playSong(song);
  }

  @override
  Future<void> pauseSong() async {
    await _dataSource.pauseSong();
  }

  @override
  Future<void> stopSong() async {
    await _dataSource.stopSong();
  }

  @override
  Future<Duration> getCurrentPosition() async {
    return _dataSource.getCurrentPosition();
  }

  @override
  Future<Stream<Duration>> getPositionStream() async {
    return _dataSource.getPositionStream();
  }
}
