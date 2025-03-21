import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/romantic_music/bloc/romantic_music_bloc.dart';
import 'package:yellow_flowers/features/romantic_music/widgets/music_list_tile.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Buscar canción',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            DropdownButton<String>(
              value: model.selectedGenre,
              onChanged: (genre) {
                model.selectGenre(genre!);
              },
              items: model.genres.map(
                (genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                },
              ).toList(),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de columnas en la cuadrícula
                  childAspectRatio: 0.8, // Relación de aspecto de los elementos
                ),
                itemCount: model.songs
                    .where(
                      (song) =>
                          song.title.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                          song.artist.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                    )
                    .length,
                itemBuilder: (context, index) {
                  final filteredSongs = model.songs
                      .where(
                        (song) =>
                            song.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                            song.artist.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                      )
                      .toList();
                  final song = filteredSongs[index];
                  return MusicListTile(
                    song: song,
                    isPlaying:
                        model.currentSong?.id == song.id && model.isPlaying,
                    onTap: () {
                      model.selectSong(song);
                      model.playSong(song);
                    },
                    isSelected: model.currentSong?.id == song.id,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
