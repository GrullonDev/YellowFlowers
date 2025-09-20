import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list.dart';
import 'package:yellow_flowers/features/music/widgets/music_player.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';

class MusicLayout extends StatelessWidget {
  const MusicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Música'),
            actions: [
              IconButton(
                tooltip: 'Ciclo y Música',
                icon: const Icon(Icons.auto_awesome_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CycleMusicPage()),
                  );
                },
              ),
            ],
          ),
          body: AnimatedBackground(
            child: model.currentSong == null
                ? const MusicList()
                : MusicPlayer(
                    model: model,
                  ),
          ),
        );
      },
    );
  }
}
