import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';

class MusicPlayer extends StatelessWidget {

  const MusicPlayer({
    super.key,
    required this.model,
    this.isMiniPlayer = false,
  });
  final MusicBloc model;
  final bool isMiniPlayer;

  @override
  Widget build(BuildContext context) {
    if (isMiniPlayer) {
      return _buildMiniPlayer(context);
    } else {
      return _buildFullPlayer(context);
    }
  }

  Widget _buildMiniPlayer(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.grey[200],
      child: Row(
        children: [
          Image.network(
            model.currentSong!.coverUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                model.currentSong!.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              model.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (model.isPlaying) {
                model.pauseSong();
              } else {
                model.playSong(model.currentSong!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(
                    red: 255,
                    green: 192,
                    blue: 203,
                  ),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                model.currentSong!.coverUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                model.currentSong!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                model.currentSong!.artist,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40),
                onPressed: () {
                  // Implementar lógica para canción anterior
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.pink[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    model.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (model.isPlaying) {
                      model.pauseSong();
                    } else {
                      model.playSong(model.currentSong!);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
