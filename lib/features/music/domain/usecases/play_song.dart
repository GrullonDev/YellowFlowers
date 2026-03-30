import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import '../entities/song_entity.dart';
import '../repositories/music_repository.dart';

class PlaySongParams {
  const PlaySongParams(this.song);
  final SongEntity song;
}

class PlaySongUseCase implements UseCase<void, PlaySongParams> {
  PlaySongUseCase(this.repository);
  final MusicRepository repository;

  @override
  Future<Result<void>> call(PlaySongParams params) {
    return repository.playSong(params.song);
  }
}
