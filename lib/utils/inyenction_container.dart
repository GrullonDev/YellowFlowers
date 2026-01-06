import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/datasource/music_remote_datasource.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/core/tts/tts_service.dart';

// Global GetIt instance for dependency injection
final get = GetIt.instance;

/// Initialize all dependencies
void initializeDependencies() {
  // Services
  _initializeServices();

  // Repositories
  _initializeRepositories();

  // ViewModels/Blocs
  _initializeViewModels();
}

/// Initialize service dependencies
void _initializeServices() {
  // Register AudioPlayer as a singleton
  get.registerLazySingleton(() => AudioPlayer());

  //Register Jamendo Api Service.
  get.registerLazySingleton(() => JamendoApiService());
  // Register TTS service (guarded to avoid duplicate registration & survive hot reload type changes)
  if (!get.isRegistered<TtsService>()) {
    get.registerLazySingleton(() => TtsService());
  }

  // Register MusicRemoteDataSource
  get.registerLazySingleton<MusicRemoteDataSource>(
    () => MusicRemoteDataSourceImpl(
      audioPlayer: get<AudioPlayer>(),
      apiService: get<JamendoApiService>(),
    ),
  );
}

/// Initialize repository dependencies
void _initializeRepositories() {
  // Register MusicRepository
  get.registerLazySingleton<MusicRemoteRepository>(
    () => MusicRemoteRepositoryImpl(
      dataSource: get<MusicRemoteDataSource>(),
    ),
  );
}

/// Initialize ViewModel/Bloc dependencies
void _initializeViewModels() {
  // Register MusicBloc
  get.registerFactory(
    () => MusicBloc(
      repository: get<MusicRemoteRepository>(),
    ),
  );
}
