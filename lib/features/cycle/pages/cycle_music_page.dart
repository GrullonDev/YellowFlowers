import 'package:flutter/material.dart';
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
    final phase = context.watch<CycleController>().currentPhase;
    final cycle = context.watch<CycleController>();
    final mood = _moodForPhase(phase, cycle);
    return BaseModelScaffold(
      model: di.sl<MusicBloc>(),
      builder: (context, model) {
        // al entrar, si el mood difiere, cargar catálogo por mood de la fase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (model.selectedMood != mood) {
            model.selectMood(mood);
          }
        });
        return Scaffold(
          appBar: AppBar(title: const Text('Ciclo y Música')),
          body: Column(
            children: [
              const CyclePhaseBar(),
              const SizedBox(height: 8),
              _DailyCombinedCard(mood: mood),
              Expanded(child: MusicLayout()),
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
      return Mood.relaxed; // calmante; si prefieres motivada: Mood.motivated
    case CyclePhase.other:
      return Mood.relaxed;
  }
}

class _DailyCombinedCard extends StatefulWidget {
  const _DailyCombinedCard({required this.mood});
  final Mood mood;

  @override
  State<_DailyCombinedCard> createState() => _DailyCombinedCardState();
}

class _DailyCombinedCardState extends State<_DailyCombinedCard> {
  String? _title;
  String? _cover;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Use the same MusicBloc provided higher (by DI) to access its dailyRecommendation when ready.
    // We'll listen once after its initial load cycle.
    final bloc = di.sl<MusicBloc>();
    // If bloc already loaded a recommendation for current mood, use it; else wait for next frame after mood selection.
    if (bloc.dailyRecommendation != null && bloc.selectedMood == widget.mood) {
      setState(() {
        _title = '${bloc.dailyRecommendation!.title} — ${bloc.dailyRecommendation!.artist}';
        _cover = bloc.dailyRecommendation!.coverUrl;
        _loading = false;
      });
    } else {
      // Wait a short microtask for bloc to fetch.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final dr = bloc.dailyRecommendation;
        setState(() {
          _title = dr != null ? '${dr.title} — ${dr.artist}' : null;
          _cover = dr?.coverUrl;
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phraseForMood(widget.mood);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _cover != null && _cover!.isNotEmpty
                    ? Image.network(_cover!, width: 72, height: 72, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: Colors.black12))
                    : Container(width: 72, height: 72, color: Colors.black12),
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
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    if (_loading)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (_title != null)
                      Text(
                        _title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text('No hay sugerencias ahora'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        final bloc = di.sl<MusicBloc>();
                        final dr = bloc.dailyRecommendation;
                        if (dr != null) {
                          await bloc.playSong(dr);
                        }
                      },
                child: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
