import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart';
import 'package:yellow_flowers/features/music/pages/music_layout.dart';
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
