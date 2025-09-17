import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import '../entities/song_entity.dart';
import '../repositories/music_repository.dart';

class PlaySongParams {
  final SongEntity song;
  const PlaySongParams(this.song);
}

class PlaySongUseCase implements UseCase<void, PlaySongParams> {
  final MusicRepository repository;
  PlaySongUseCase(this.repository);

  @override
  Future<Result<void>> call(PlaySongParams params) {
    return repository.playSong(params.song);
  }
}
