import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/music/domain/entities/song_entity.dart';
import 'package:yellow_flowers/features/music/domain/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteRepository remote;
  MusicRepositoryImpl({required this.remote});

  SongEntity _map(Song s) => SongEntity(
        id: s.id,
        title: s.title,
        artist: s.artist,
        audioUrl: s.audioUrl,
        coverUrl: s.coverUrl,
        duration: s.duration,
        genre: s.genre,
      );

  Future<Result<List<SongEntity>>> _guardList(Future<List<Song>> Function() block) async {
    try {
      final list = await block();
      return Success(list.map(_map).toList());
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  Future<Result<SongEntity?>> _guardSong(Future<Song?> Function() block) async {
    try {
      final song = await block();
      return Success(song == null ? null : _map(song));
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  Future<Result<void>> _guardVoid(Future<void> Function() block) async {
    try {
      await block();
      return const Success(null);
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<SongEntity>>> getSongs(String genre) => _guardList(() => remote.getSongs(genre));

  @override
  Future<Result<List<SongEntity>>> getSongsByMood(Mood mood) => _guardList(() => remote.getSongsByMood(mood));

  @override
  Future<Result<SongEntity?>> getDailyRecommendation(Mood mood) => _guardSong(() => remote.getDailyRecommendation(mood));

  @override
  Future<Result<void>> pauseSong() => _guardVoid(() => remote.pauseSong());

  @override
  Future<Result<void>> playSong(SongEntity song) => _guardVoid(() => remote.playSong(Song(
        id: song.id,
        title: song.title,
        artist: song.artist,
        audioUrl: song.audioUrl,
        coverUrl: song.coverUrl,
        duration: song.duration,
        genre: song.genre,
      )));

  @override
  Future<Result<void>> stopSong() => _guardVoid(() => remote.stopSong());

  @override
  Future<Result<Duration>> getCurrentPosition() async {
    try {
      final d = await remote.getCurrentPosition();
      return Success(d);
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<Stream<Duration>>> getPositionStream() async {
    try {
      final s = await remote.getPositionStream();
      return Success(s);
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }
}
