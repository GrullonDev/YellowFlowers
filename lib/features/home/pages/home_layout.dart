import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/core/tts/tts_service.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/widgets/premium_widgets.dart';
import 'package:yellow_flowers/core/transitions.dart';

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Flores Amarillas',
            style: PremiumDesign.serifSubHeading.copyWith(
              fontSize: 22,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: AnimatedBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(PremiumDesign.s24),
              physics: const BouncingScrollPhysics(),
              children: [
                const _HeroHeader(),
                const SizedBox(height: PremiumDesign.s32),
                const _SmartSuggestionCard(),
                const SizedBox(height: PremiumDesign.s24),
                const _DailyMoodCard(),
                const SizedBox(height: PremiumDesign.s16),
                const _WellnessExercisesCard(),
                const SizedBox(height: PremiumDesign.s16),
                const _EmotionTrackerCard(),
                const SizedBox(height: PremiumDesign.s32),
                Text(
                  'Tu jardín de experiencias',
                  style: PremiumDesign.serifSubHeading.copyWith(
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: PremiumDesign.s16),
                ...List.generate(model.menuItems.length, (index) {
                  final item = model.menuItems[index];
                  final cardStyle = _cardStyleForIndex(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: PremiumDesign.s16),
                    child: _MenuCard(
                      item: item,
                      gradient: cardStyle.gradient,
                      iconColor: cardStyle.iconColor,
                      index: index,
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

// ─── Hero Header ────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isFlowerDay = now.month == 3 && now.day == 21;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(PremiumDesign.s24),
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFlowerDay ? '¡Día de las\nFlores! 🌻' : '¡Hola, hermosa! 🌻',
                  style: GoogleFonts.pacifico(
                    fontSize: 24,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: PremiumDesign.s8),
                Text(
                  isFlowerDay
                      ? '21 de marzo · Un día para brillar'
                      : 'Cada día es una flor nueva',
                  style: PremiumDesign.sansBody.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PremiumDesign.s12),
          const _FloatingFlowerStack(),
        ],
      ),
    );
  }
}


class _FloatingFlowerStack extends StatefulWidget {
  const _FloatingFlowerStack();

  @override
  State<_FloatingFlowerStack> createState() => _FloatingFlowerStackState();
}

class _FloatingFlowerStackState extends State<_FloatingFlowerStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final lift = _anim.value * 6;
        return Transform.translate(
          offset: Offset(0, -lift),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text('🌸', style: TextStyle(fontSize: 22 + _anim.value * 2)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Text('🌺', style: TextStyle(fontSize: 20 + _anim.value * 2)),
                ),
                Text('🌻', style: TextStyle(fontSize: 36 + _anim.value * 4)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SmartSuggestionCard extends StatelessWidget {
  const _SmartSuggestionCard();

  @override
  Widget build(BuildContext context) {
    final personalization = di.sl<PersonalizationService>();
    final recommendation = personalization.getRecommendation();

    return GlassCard(
      padding: const EdgeInsets.all(PremiumDesign.s24),
      color: PremiumDesign.radiantGold.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PremiumDesign.s8),
                decoration: BoxDecoration(
                  color: PremiumDesign.radiantGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: PremiumDesign.radiantGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: PremiumDesign.s12),
              Text(
                'Hoy te recomendamos esto 💛',
                style: PremiumDesign.sansLabel.copyWith(
                  color: PremiumDesign.radiantGold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumDesign.s16),
          Text(
            recommendation,
            style: PremiumDesign.sansBody.copyWith(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PremiumDesign.s16),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Logic to apply mood would go here if we had a multi-mood apply
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: Size.zero,
            ),
            child: const Text('Descubrir'),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Card ───────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final dynamic item;
  final LinearGradient gradient;
  final Color iconColor;
  final int index;

  const _MenuCard({
    required this.item,
    required this.gradient,
    required this.iconColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PremiumTransitions.fadeThrough(item.destination),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Color(0xFF8D6E63)),
            ],
          ),
        ),
      ),
    );
  }
}

_CardStyle _cardStyleForIndex(int index) {
  const styles = [
    _CardStyle(
      gradient: LinearGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFEC9E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: Color(0xFFFFB300),
    ),
    _CardStyle(
      gradient: LinearGradient(
        colors: [Color(0xFFFFE4EC), Color(0xFFFFC1D9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: Color(0xFFE91E8C),
    ),
    _CardStyle(
      gradient: LinearGradient(
        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: Color(0xFF43A047),
    ),
    _CardStyle(
      gradient: LinearGradient(
        colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: Color(0xFF7E57C2),
    ),
    _CardStyle(
      gradient: LinearGradient(
        colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: Color(0xFF0097A7),
    ),
  ];
  return styles[index % styles.length];
}

class _CardStyle {
  final LinearGradient gradient;
  final Color iconColor;
  const _CardStyle({required this.gradient, required this.iconColor});
}

// ─── Daily Mood Card ─────────────────────────────────────────────────────────

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
    if (_lastPhraseKey != phrase) {
      _lastPhraseKey = phrase;
      _tts.stop();
    }
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE4B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('💌', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu frase de hoy',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    phrase,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: const Color(0xFF4E342E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TtsState>(
              valueListenable: _tts.stateNotifier,
              builder: (context, state, _) {
                final isSpeaking = state == TtsState.speaking;
                final isInit = state == TtsState.initializing;
                return FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  onPressed: isInit ? null : () => _toggleTts(phrase),
                  child: isInit
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          isSpeaking
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          size: 20,
                        ),
                );
              },
            ),
          ],
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

// ─── Wellness Card ───────────────────────────────────────────────────────────

class _WellnessExercisesCard extends StatelessWidget {
  const _WellnessExercisesCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('🧘', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bienestar: respira y afírmate hoy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _GreenOutlineButton(
              label: 'Respirar',
              onPressed: () => _startBreathing(context),
            ),
            const SizedBox(width: 6),
            _GreenFilledButton(
              label: 'Afirmar',
              onPressed: () => _speakAffirmations(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreenOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GreenOutlineButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2E7D32),
        side: const BorderSide(color: Color(0xFF43A047)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _GreenFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GreenFilledButton({required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF43A047),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

// ─── Emotion Tracker Card ─────────────────────────────────────────────────────

class _EmotionTrackerCard extends StatelessWidget {
  const _EmotionTrackerCard();
  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WellnessController>();
    final last7 = wc.last7Days();
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4EC), Color(0xFFF8BBD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF48FB1).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌈', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Tu ánimo esta semana',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF880E4F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: Emotion.values.map((e) {
                final selected = wc.emotionOf(wc.todayKey) == e;
                return ChoiceChip(
                  label: Text(
                    _labelForEmotion(e),
                    style: GoogleFonts.lato(fontSize: 12),
                  ),
                  selected: selected,
                  selectedColor: _colorForEmotion(e),
                  onSelected: (_) => wc.setEmotionToday(e),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 22,
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

// ─── Animated Leading Icon ────────────────────────────────────────────────────

class _AnimatedLeadingIcon extends StatelessWidget {
  final IconData icon;
  final double progress;
  final Color color;

  const _AnimatedLeadingIcon({
    required this.icon,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    final isMusic = icon == Icons.music_note || icon == Icons.music_note_outlined;
    final sway = math.sin(t * 2 * math.pi) * 0.08;
    final lift = math.sin(t * 2 * math.pi) * (isMusic ? 2.0 : 1.0);
    return Transform.translate(
      offset: Offset(0, -lift),
      child: Transform.rotate(
        angle: sway,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

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
      return 'Feliz 💛';
    case Emotion.relaxed:
      return 'Tranquila 🌿';
    case Emotion.romantic:
      return 'Romántica 💖';
    case Emotion.motivated:
      return 'Motivada ✨';
    case Emotion.nostalgic:
      return 'Nostálgica 🌙';
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
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Respiración 4-4-4 🌬️'),
      content: const Text('Inhala 4s · Sostén 4s · Exhala 4s.\nRepite 5 veces y siente la calma.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Listo 🌸'))
      ],
    ),
  );
}

Future<void> _speakAffirmations(BuildContext context) async {
  const affirmations = [
    'Soy suficiente. Hoy avanzo con calma y confianza.',
    'Merezco amor, paz y todo lo hermoso que la vida tiene.',
    'Soy fuerte, capaz y llena de luz.',
  ];
  final text = affirmations[(DateTime.now().day) % affirmations.length];
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tu afirmación de hoy 🌟'),
      content: Text(text,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Gracias 💛'))
      ],
    ),
  );
}
