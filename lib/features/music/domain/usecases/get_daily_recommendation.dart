import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import '../entities/song_entity.dart';
import '../repositories/music_repository.dart';

class GetDailyRecommendationParams {
  final Mood mood;
  const GetDailyRecommendationParams(this.mood);
}

class GetDailyRecommendationUseCase implements UseCase<SongEntity?, GetDailyRecommendationParams> {
  final MusicRepository repository;
  GetDailyRecommendationUseCase(this.repository);

  @override
  Future<Result<SongEntity?>> call(GetDailyRecommendationParams params) {
    return repository.getDailyRecommendation(params.mood);
  }
}
