import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_songs_by_mood.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_daily_recommendation.dart';
import 'package:yellow_flowers/features/music/domain/usecases/play_song.dart';
import 'package:yellow_flowers/features/music/domain/usecases/pause_song.dart';
import 'package:yellow_flowers/features/music/domain/usecases/get_position_stream.dart';
import 'package:yellow_flowers/features/music/pages/music_layout.dart';
import 'package:yellow_flowers/utils/base_model_scaffold.dart';
import 'package:yellow_flowers/utils/inyenction_container.dart' as sl; // legacy
import 'package:yellow_flowers/di/injector.dart' as new_di; // new

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModelScaffold(
      model: MusicBloc(
        repository: sl.get<MusicRemoteRepository>(), // legacy repo
        getSongsByMoodUseCase: new_di.sl.isRegistered<GetSongsByMoodUseCase>() ? new_di.sl<GetSongsByMoodUseCase>() : null,
        getDailyRecommendationUseCase: new_di.sl.isRegistered<GetDailyRecommendationUseCase>() ? new_di.sl<GetDailyRecommendationUseCase>() : null,
        playSongUseCase: new_di.sl.isRegistered<PlaySongUseCase>() ? new_di.sl<PlaySongUseCase>() : null,
        pauseSongUseCase: new_di.sl.isRegistered<PauseSongUseCase>() ? new_di.sl<PauseSongUseCase>() : null,
        getPositionStreamUseCase: new_di.sl.isRegistered<GetPositionStreamUseCase>() ? new_di.sl<GetPositionStreamUseCase>() : null,
      ),
      builder: (context, _) => const MusicLayout(),
    );
  }
}
