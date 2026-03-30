import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import '../repositories/music_repository.dart';

class GetPositionStreamUseCase implements UseCase<Stream<Duration>, NoParams> {
  GetPositionStreamUseCase(this.repository);
  final MusicRepository repository;

  @override
  Future<Result<Stream<Duration>>> call(NoParams params) {
    return repository.getPositionStream();
  }
}
