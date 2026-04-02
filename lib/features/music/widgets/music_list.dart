import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list_tile.dart';

class MusicList extends StatelessWidget {
  const MusicList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: PremiumDesign.radiantGold,
              strokeWidth: 2,
            ),
          );
        }

        if (model.songs.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PremiumDesign.s32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐚', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron canciones',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesign.softText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.errorMessage ?? 'Inténtalo de nuevo más tarde.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: PremiumDesign.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _RetryButton(onTap: () => model.retry()),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              PremiumDesign.s24, 0, PremiumDesign.s24, 80),
          itemCount: model.songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final song = model.songs[index];
            return MusicListTile(
              song: song,
              isPlaying: model.currentSong?.id == song.id && model.isPlaying,
              onTap: () {
                model.selectSong(song);
                model.playSong(song);
              },
              isSelected: model.currentSong?.id == song.id,
            );
          },
        );
      },
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: PremiumDesign.premiumGold.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Reintentar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: PremiumDesign.premiumGold,
          ),
        ),
      ),
    );
  }
}
