import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/album_card.dart';

class MomentsGalleryLayout extends StatelessWidget {
  const MomentsGalleryLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Galería de Momentos'),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: model.albums.length,
          itemBuilder: (context, i) {
            final album = model.albums[i];
            return AlbumCard(
              title: '${album.emoji} ${album.label}',
              icon: album.icon,
              colors: album.colors,
              onTap: () => model.onTapAlbum(context, album),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => model.pickAndSaveMemory(context),
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Nuevo recuerdo'),
        ),
      ),
    );
  }
}
