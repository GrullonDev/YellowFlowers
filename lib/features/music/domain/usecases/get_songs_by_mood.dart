import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import '../entities/song_entity.dart';
import '../repositories/music_repository.dart';

class GetSongsByMoodParams {
  final Mood mood;
  const GetSongsByMoodParams(this.mood);
}

class GetSongsByMoodUseCase implements UseCase<List<SongEntity>, GetSongsByMoodParams> {
  final MusicRepository repository;
  GetSongsByMoodUseCase(this.repository);

  @override
  Future<Result<List<SongEntity>>> call(GetSongsByMoodParams params) {
    return repository.getSongsByMood(params.mood);
  }
}
