import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/album_card.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class MomentsGalleryLayout extends StatelessWidget {
  const MomentsGalleryLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, model, _) => Scaffold(
        backgroundColor: const Color(0xFFF9F5EC), // Papel antiguo
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFF9F5EC),
              floating: true,
              centerTitle: true,
              title: Text(
                'Nuestros Recuerdos',
                style: GoogleFonts.playball(
                  color: AppTheme.textDark,
                  fontSize: 28,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85, // Más alto para el efecto polaroid
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final album = model.albums[i];
                    // Rotación aleatoria determinista basada en el índice
                    final double rotation =
                        ((i % 2 == 0 ? -1 : 1) * (0.02 + (i * 0.01) % 0.04));

                    return AlbumCard(
                      title: '${album.emoji} ${album.label}',
                      icon: album.icon,
                      colors: album.colors,
                      rotation: rotation,
                      onTap: () => model.onTapAlbum(context, album),
                    );
                  },
                  childCount: model.albums.length,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => model.pickAndSaveMemory(context),
          backgroundColor: AppTheme.sunnyGold,
          icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          label: Text(
            'Nuevo Recuerdo',
            style: GoogleFonts.gaegu(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
