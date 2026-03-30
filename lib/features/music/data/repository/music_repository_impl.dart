import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/music/domain/entities/song_entity.dart';
import 'package:yellow_flowers/features/music/domain/repositories/music_repository.dart';

import 'package:yellow_flowers/features/music/data/datasource/music_local_datasource.dart';

class MusicRepositoryImpl implements MusicRepository {
  MusicRepositoryImpl({required this.remote, required this.local});
  final MusicRemoteRepository remote;
  final MusicLocalDataSource local;

  SongEntity _map(Song s) => SongEntity(
        id: s.id,
        title: s.title,
        artist: s.artist,
        audioUrl: s.audioUrl,
        coverUrl: s.coverUrl,
        duration: s.duration,
        genre: s.genre,
      );

  Future<Result<void>> _guardVoid(Future<void> Function() block) async {
    try {
      await block();
      return const Success(null);
    } catch (e, st) {
      return Error(UnknownFailure(e.toString(), cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<List<SongEntity>>> getSongs(String genre) async {
    try {
      final list = await remote.getSongs(genre);
      await local.cacheSongs(genre, list);
      return Success(list.map(_map).toList());
    } catch (e) {
      final cached = await local.getCachedSongs(genre);
      if (cached.isNotEmpty) return Success(cached.map(_map).toList());
      return Error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SongEntity>>> getSongsByMood(Mood mood) async {
    try {
      final list = await remote.getSongsByMood(mood);
      await local.cacheSongs(mood.name, list);
      return Success(list.map(_map).toList());
    } catch (e) {
      final cached = await local.getCachedSongs(mood.name);
      if (cached.isNotEmpty) return Success(cached.map(_map).toList());
      return Error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<SongEntity?>> getDailyRecommendation(Mood mood) async {
    try {
      final song = await remote.getDailyRecommendation(mood);
      if (song != null) await local.cacheRecommendation(mood, song);
      return Success(song == null ? null : _map(song));
    } catch (e) {
      final cached = await local.getCachedRecommendation(mood);
      if (cached != null) return Success(_map(cached));
      return Error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> pauseSong() => _guardVoid(() => remote.pauseSong());

  @override
  Future<Result<void>> playSong(SongEntity song) =>
      _guardVoid(() => remote.playSong(Song(
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
