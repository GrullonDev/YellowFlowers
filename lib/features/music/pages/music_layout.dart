import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list.dart';
import 'package:yellow_flowers/features/music/widgets/music_player.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';

/// Pantalla completa con Scaffold + AppBar para navegar directamente a música.
class MusicLayout extends StatelessWidget {
  const MusicLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, _) => Scaffold(
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
        body: MusicBody(model: model),
      ),
    );
  }
}

/// Sólo el cuerpo del reproductor, sin Scaffold.
/// Usar este widget cuando se necesite embeber música dentro de otra pantalla.
class MusicBody extends StatelessWidget {
  const MusicBody({super.key, required this.model});
  final MusicBloc model;

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: model.currentSong == null
          ? const MusicList()
          : MusicPlayer(model: model),
    );
  }
}
