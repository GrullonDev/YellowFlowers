import 'package:yellow_flowers/core/result.dart';
import 'package:yellow_flowers/core/usecase.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import '../entities/song_entity.dart';
import '../repositories/music_repository.dart';

class GetDailyRecommendationParams {
  const GetDailyRecommendationParams(this.mood);
  final Mood mood;
}

class GetDailyRecommendationUseCase
    implements UseCase<SongEntity?, GetDailyRecommendationParams> {
  GetDailyRecommendationUseCase(this.repository);
  final MusicRepository repository;

  @override
  Future<Result<SongEntity?>> call(GetDailyRecommendationParams params) {
    return repository.getDailyRecommendation(params.mood);
  }
}
