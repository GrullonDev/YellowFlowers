import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list_tile.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // Empty/error state
        final hasSongs = model.songs.isNotEmpty;
        if (!hasSongs) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _MoodChipsOnly(),
                const SizedBox(height: 24),
                const Icon(Icons.music_off, size: 48, color: Colors.black45),
                const SizedBox(height: 12),
                Text(
                  'No se encontraron canciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (model.errorMessage != null)
                  Text(
                    model.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => model.retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Asegúrate de configurar JAMENDO_CLIENT_ID al ejecutar la app.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black45),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            const _MoodChipsOnly(),

            // Daily recommendation
            if (model.dailyRecommendation != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Text('🌸', style: TextStyle(fontSize: 24)),
                    title: const Text('Tu canción del día'),
                    subtitle: Text(
                      '${model.dailyRecommendation!.title} — ${model.dailyRecommendation!.artist}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final s = model.dailyRecommendation!;
                      model.selectSong(s);
                      model.playSong(s);
                    },
                  ),
                ),
              ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de columnas en la cuadrícula
                  childAspectRatio: 0.8, // Relación de aspecto de los elementos
                ),
                itemCount: model.songs.length,
                itemBuilder: (context, index) {
                  final song = model.songs[index];
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

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.mood,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final Mood mood;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
    );
  }
}

class _MoodChipsOnly extends StatelessWidget {
  const _MoodChipsOnly();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MusicBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MoodChip(label: 'Tranquila', mood: Mood.relaxed, selected: model.selectedMood == Mood.relaxed, onSelected: () => model.selectMood(Mood.relaxed)),
          _MoodChip(label: 'Romántica', mood: Mood.romantic, selected: model.selectedMood == Mood.romantic, onSelected: () => model.selectMood(Mood.romantic)),
          _MoodChip(label: 'Motivada', mood: Mood.motivated, selected: model.selectedMood == Mood.motivated, onSelected: () => model.selectMood(Mood.motivated)),
          _MoodChip(label: 'Nostálgica', mood: Mood.nostalgic, selected: model.selectedMood == Mood.nostalgic, onSelected: () => model.selectMood(Mood.nostalgic)),
          _MoodChip(label: 'Feliz', mood: Mood.happy, selected: model.selectedMood == Mood.happy, onSelected: () => model.selectMood(Mood.happy)),
        ],
      ),
    );
  }
}
