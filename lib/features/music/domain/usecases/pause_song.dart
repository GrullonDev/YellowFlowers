import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import '../repositories/music_repository.dart';

class PauseSongUseCase implements UseCase<void, NoParams> {
  PauseSongUseCase(this.repository);
  final MusicRepository repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return repository.pauseSong();
  }
}
