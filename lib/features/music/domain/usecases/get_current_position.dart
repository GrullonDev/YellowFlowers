import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import '../repositories/music_repository.dart';

class GetCurrentPositionUseCase implements UseCase<Duration, NoParams> {
  final MusicRepository repository;
  GetCurrentPositionUseCase(this.repository);

  @override
  Future<Result<Duration>> call(NoParams params) {
    return repository.getCurrentPosition();
  }
}
