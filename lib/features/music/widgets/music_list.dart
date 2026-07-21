import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list_tile.dart';
import 'package:yellow_flowers/widgets/app_error_view.dart';

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
          // model.errorMessage (set by MusicBloc via friendlyErrorMessage)
          // distinguishes "genuinely no songs for this mood" from a
          // network/timeout failure, but both degrade to the same
          // reassuring empty state with a retry action.
          return AppErrorView(
            title: 'No se encontraron canciones',
            message: model.errorMessage ??
                'Prueba con otro estado de ánimo o inténtalo de nuevo.',
            onRetry: () => model.retry(),
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
