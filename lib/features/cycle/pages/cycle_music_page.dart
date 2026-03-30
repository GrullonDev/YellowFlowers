import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/cycle/widgets/cycle_phase_bar.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/pages/music_layout.dart';
import 'package:yellow_flowers/utils/base_model_scaffold.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';

class CycleMusicPage extends StatelessWidget {
  const CycleMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleController>();
    final mood = _moodForPhase(cycle.currentPhase, cycle);

    return BaseModelScaffold(
      model: di.sl<MusicBloc>(),
      builder: (context, model) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (model.selectedMood != mood) model.selectMood(mood);
        });
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Ciclo y Música',
              style: GoogleFonts.pacifico(fontSize: 20),
            ),
          ),
          body: Column(
            children: [
              const CyclePhaseBar(),
              const SizedBox(height: 8),
              _DailyCombinedCard(mood: mood),
              const SizedBox(height: 4),
              // MusicBody reutiliza el mismo MusicBloc del BaseModelScaffold
              Expanded(child: MusicBody(model: model)),
            ],
          ),
        );
      },
    );
  }
}

Mood _moodForPhase(CyclePhase p, CycleController cycle) {
  switch (p) {
    case CyclePhase.premenstrual:
      return Mood.relaxed;
    case CyclePhase.fertile:
      return cycle.fertilePreferEnergetic ? Mood.motivated : Mood.romantic;
    case CyclePhase.period:
      return Mood.relaxed;
    case CyclePhase.other:
      return Mood.relaxed;
  }
}

class _DailyCombinedCard extends StatelessWidget {
  const _DailyCombinedCard({required this.mood});
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    // Usa el mismo MusicBloc provisto por BaseModelScaffold en el contexto
    final bloc = context.watch<MusicBloc>();
    final song = bloc.dailyRecommendation;
    final phrase = _phraseForMood(mood);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: song?.coverUrl.isNotEmpty == true
                    ? Image.network(
                        song!.coverUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoy: $phrase',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    if (bloc.isLoading)
                      const SizedBox(
                          height: 2,
                          child: LinearProgressIndicator(minHeight: 2))
                    else if (song != null)
                      Text(
                        '${song.title} — ${song.artist}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(fontSize: 13),
                      )
                    else
                      Text(
                        'No hay sugerencias ahora',
                        style: GoogleFonts.lato(
                            fontSize: 13, color: Colors.black54),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: (bloc.isLoading || song == null)
                    ? null
                    : () => bloc.playSong(song),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFF8BBD0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.music_note_rounded,
            color: Color(0xFFE91E8C), size: 28),
      );
}

String _phraseForMood(Mood mood) {
  switch (mood) {
    case Mood.motivated:
      return 'un impulso de energía ✨';
    case Mood.nostalgic:
      return 'una melodía para recordar 🌙';
    case Mood.romantic:
      return 'deja que la música hable por ti 💖';
    case Mood.happy:
      return 'sube el ánimo y sonríe 💛';
    case Mood.relaxed:
      return 'un respiro para el alma 🌿';
  }
}
