import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/features/music/data/datasource/music_local_datasource.dart';

import 'package:yellow_flowers/core/tts/tts_service.dart';
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/datasource/music_remote_datasource.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/music/data/repository/music_repository_impl.dart';
import 'package:yellow_flowers/features/music/domain/repositories/music_repository.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_current_position.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_daily_recommendation.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_position_stream.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_songs_by_mood.dart';
import 'package:yellow_flowers/features/music/domain/usecases/pause_song.dart';
import 'package:yellow_flowers/features/music/domain/usecases/play_song.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<PersonalizationService>(PersonalizationService(prefs));

  // Services
  sl.registerLazySingleton<JamendoApiService>(
      () => JamendoApiService(client: sl()));
  // Guarded registration for TTS to avoid duplicate registration errors during hot reload
  if (!sl.isRegistered<TtsService>()) {
    sl.registerLazySingleton<TtsService>(() => TtsService());
  }

  // Data sources
  sl.registerLazySingleton<MusicLocalDataSource>(
      () => MusicLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<MusicRemoteDataSource>(
      () => MusicRemoteDataSourceImpl(audioPlayer: sl(), apiService: sl()));

  // Legacy repository
  sl.registerLazySingleton<MusicRemoteRepository>(
      () => MusicRemoteRepositoryImpl(dataSource: sl()));

  // Domain repository wrapper
  sl.registerLazySingleton<MusicRepository>(
      () => MusicRepositoryImpl(remote: sl(), local: sl()));

  // Use cases
  sl.registerFactory(() => GetSongsByMoodUseCase(sl()));
  sl.registerFactory(() => GetDailyRecommendationUseCase(sl()));
  sl.registerFactory(() => PlaySongUseCase(sl()));
  sl.registerFactory(() => PauseSongUseCase(sl()));
  sl.registerFactory(() => GetPositionStreamUseCase(sl()));
  sl.registerFactory(() => GetCurrentPositionUseCase(sl()));

  // Presentation (Bloc)
  sl.registerFactory(() => MusicBloc(
        repository:
            sl(), // legacy remote repo wrapper still used internally by bloc for fallback
        getSongsByMoodUseCase:
            sl.isRegistered<GetSongsByMoodUseCase>() ? sl() : null,
        getDailyRecommendationUseCase:
            sl.isRegistered<GetDailyRecommendationUseCase>() ? sl() : null,
        playSongUseCase: sl.isRegistered<PlaySongUseCase>() ? sl() : null,
        pauseSongUseCase: sl.isRegistered<PauseSongUseCase>() ? sl() : null,
        getPositionStreamUseCase:
            sl.isRegistered<GetPositionStreamUseCase>() ? sl() : null,
      ));
}
