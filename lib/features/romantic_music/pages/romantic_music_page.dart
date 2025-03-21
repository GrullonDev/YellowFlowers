import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/romantic_music/bloc/romantic_music_bloc.dart';
import 'package:yellow_flowers/features/romantic_music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/romantic_music/pages/romantic_music_layout.dart';
import 'package:yellow_flowers/utils/base_model_scaffold.dart';
import 'package:yellow_flowers/utils/inyenction_container.dart' as sl;

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModelScaffold(
      model: MusicBloc(
        repository: sl.get<MusicRemoteRepository>(),
      ),
      builder: (context, _) => const MusicLayout(),
    );
  }
}
