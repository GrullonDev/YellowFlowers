import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
// import 'package:yellow_flowers/features/music/data/repository/music_remote_repository.dart'; // ya no usado en frase diaria
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/core/tts/tts_service.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Elige tu experiencia ✨',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: AnimatedBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                const _DailyMoodCard(),
                const SizedBox(height: 12),
                const _WellnessExercisesCard(),
                const SizedBox(height: 12),
                const _EmotionTrackerCard(),
                const SizedBox(height: 16),
                ...List.generate(model.menuItems.length, (index) {
                  final item = model.menuItems[index];
                  final color = Colors.pink[300]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: _AnimatedLeadingIcon(
                            icon: item.icon, progress: 0.0, color: color),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(item.description,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => item.destination,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(progress);
    final isMusic =
        icon == Icons.music_note || icon == Icons.music_note_outlined;
    final sway = math.sin(t * 2 * math.pi) * 0.08;
    final lift = math.sin(t * 2 * math.pi) * (isMusic ? 2.0 : 1.0);
    return Transform.translate(
      offset: Offset(0, -lift),
      child: Transform.rotate(
        angle: sway,
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}

class _DailyMoodCard extends StatefulWidget {
  const _DailyMoodCard();
  @override
  State<_DailyMoodCard> createState() => _DailyMoodCardState();
}

class _DailyMoodCardState extends State<_DailyMoodCard> {
  String _lastPhraseKey = '';

  TtsService get _tts => di.sl<TtsService>();

  @override
  Widget build(BuildContext context) {
    final mood = context.watch<MoodController>().mood;
    final wc = context.watch<WellnessController>();
    final phrase = wc.dailyPhrase(emotion: _toEmotion(mood));
    // Si la frase cambió, detener TTS automáticamente
    if (_lastPhraseKey != phrase) {
      _lastPhraseKey = phrase;
      _tts.stop();
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Text('💌', style: TextStyle(fontSize: 22)),
        title: const Text('Tu frase de hoy',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(phrase, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: ValueListenableBuilder<TtsState>(
          valueListenable: _tts.stateNotifier,
          builder: (context, state, _) {
            final isSpeaking = state == TtsState.speaking;
            final isInit = state == TtsState.initializing;
            return FilledButton(
              onPressed: isInit ? null : () => _toggleTts(phrase),
              child: isInit
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isSpeaking
                      ? Icons.stop_rounded
                      : Icons.volume_up_rounded),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleTts(String phrase) async {
    if (_tts.state == TtsState.speaking) {
      await _tts.stop();
    } else {
      await _tts.speak(phrase);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class _WellnessExercisesCard extends StatelessWidget {
  const _WellnessExercisesCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('🧘', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Bienestar: respira y afírmate hoy',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => _startBreathing(context),
              child: const Text('Respirar'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _speakAffirmations(context),
              child: const Text('Afirmaciones'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionTrackerCard extends StatelessWidget {
  const _EmotionTrackerCard();
  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WellnessController>();
    final last7 = wc.last7Days();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu ánimo',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Emotion.values.map((e) {
                final selected = wc.emotionOf(wc.todayKey) == e;
                return ChoiceChip(
                  label: Text(_labelForEmotion(e)),
                  selected: selected,
                  onSelected: (_) => wc.setEmotionToday(e),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(7, (i) {
                  final emo = last7[i];
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == 6 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: _colorForEmotion(emo),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Emotion _toEmotion(Mood m) {
  switch (m) {
    case Mood.happy:
      return Emotion.happy;
    case Mood.relaxed:
      return Emotion.relaxed;
    case Mood.romantic:
      return Emotion.romantic;
    case Mood.motivated:
      return Emotion.motivated;
    case Mood.nostalgic:
      return Emotion.nostalgic;
  }
}

String _labelForEmotion(Emotion e) {
  switch (e) {
    case Emotion.happy:
      return 'Feliz';
    case Emotion.relaxed:
      return 'Tranquila';
    case Emotion.romantic:
      return 'Romántica';
    case Emotion.motivated:
      return 'Motivada';
    case Emotion.nostalgic:
      return 'Nostálgica';
  }
}

Color _colorForEmotion(Emotion? e) {
  switch (e) {
    case Emotion.happy:
      return const Color(0xFFFFE082);
    case Emotion.relaxed:
      return const Color(0xFFB2EBF2);
    case Emotion.romantic:
      return const Color(0xFFFFC1D9);
    case Emotion.motivated:
      return const Color(0xFFFFCC80);
    case Emotion.nostalgic:
      return const Color(0xFFB39DDB);
    default:
      return Colors.grey.shade200;
  }
}

Future<void> _startBreathing(BuildContext context) async {
  // MVP: mostrar un dialogo con ritmo simple 4-4-4
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Respiración 4-4-4'),
      content: const Text('Inhala 4s · Sostén 4s · Exhala 4s. Repite 5 veces.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Listo'))
      ],
    ),
  );
}

Future<void> _speakAffirmations(BuildContext context) async {
  // MVP: mostramos afirmaciones; si ya usas TTS en SpecialMessagesBloc podríamos reutilizarlo.
  const text = 'Soy suficiente. Hoy avanzo con calma y confianza.';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Afirmación'),
      content: const Text(text),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))
      ],
    ),
  );
}
