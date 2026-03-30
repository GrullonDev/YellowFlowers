import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class MoodEntryPage extends StatelessWidget {
  const MoodEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodController>(
      builder: (context, moodController, _) {
        final palette = _paletteForMood(moodController.mood);
        return PopScope(
          canPop: false,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                '¿Cómo te sientes hoy? 🌸',
                style: GoogleFonts.pacifico(
                  color: const Color(0xFF4E342E),
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            ),
            body: AnimatedBackground(
              topColorBegin: palette.topStart,
              topColorEnd: palette.topEnd,
              bottomColorBegin: palette.bottomStart,
              bottomColorEnd: palette.bottomEnd,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Elige tu estado de ánimo\npara personalizar tu experiencia',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: const Color(0xFF5D4037),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MoodCard(
                        label: 'Alegre',
                        emoji: '💛',
                        description: 'Energía positiva y sonrisas',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderColor: const Color(0xFFFFB300),
                        isSelected: moodController.mood == Mood.happy,
                        onTap: () async {
                          await moodController.setMood(Mood.happy);
                          if (context.mounted) Navigator.pop(context, true);
                        },
                      ),
                      const SizedBox(height: 12),
                      _MoodCard(
                        label: 'Tranquila',
                        emoji: '🌿',
                        description: 'Serenidad y paz interior',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderColor: const Color(0xFF00ACC1),
                        isSelected: moodController.mood == Mood.relaxed,
                        onTap: () async {
                          await moodController.setMood(Mood.relaxed);
                          if (context.mounted) Navigator.pop(context, true);
                        },
                      ),
                      const SizedBox(height: 12),
                      _MoodCard(
                        label: 'Enamorada',
                        emoji: '💖',
                        description: 'Ternura y romanticismo',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE4EC), Color(0xFFFFC1D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderColor: const Color(0xFFE91E8C),
                        isSelected: moodController.mood == Mood.romantic,
                        onTap: () async {
                          await moodController.setMood(Mood.romantic);
                          if (context.mounted) Navigator.pop(context, true);
                        },
                      ),
                      const SizedBox(height: 12),
                      _MoodCard(
                        label: 'Motivada',
                        emoji: '✨',
                        description: 'Fuerza, enfoque y determinación',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderColor: const Color(0xFFF57C00),
                        isSelected: moodController.mood == Mood.motivated,
                        onTap: () async {
                          await moodController.setMood(Mood.motivated);
                          if (context.mounted) Navigator.pop(context, true);
                        },
                      ),
                      const SizedBox(height: 12),
                      _MoodCard(
                        label: 'Nostálgica',
                        emoji: '🌙',
                        description: 'Recuerdos y momentos especiales',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderColor: const Color(0xFF7E57C2),
                        isSelected: moodController.mood == Mood.nostalgic,
                        onTap: () async {
                          await moodController.setMood(Mood.nostalgic);
                          if (context.mounted) Navigator.pop(context, true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.label,
    required this.emoji,
    required this.description,
    required this.gradient,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String description;
  final LinearGradient gradient;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? borderColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: isSelected ? 0.4 : 0.15),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: borderColor, size: 22)
              else
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF8D6E63), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Palette {
  const _Palette(this.topStart, this.topEnd, this.bottomStart, this.bottomEnd);
  final Color topStart;
  final Color topEnd;
  final Color bottomStart;
  final Color bottomEnd;
}

_Palette _paletteForMood(Mood mood) {
  switch (mood) {
    case Mood.happy:
      return const _Palette(Color(0xFFFFF7C2), Color(0xFFFFE8A3),
          Color(0xFFFFD3B6), Color(0xFFFFB347));
    case Mood.nostalgic:
      return const _Palette(Color(0xFFD1C4E9), Color(0xFFB39DDB),
          Color(0xFF9575CD), Color(0xFF7E57C2));
    case Mood.romantic:
      return const _Palette(Color(0xFFFFE4EC), Color(0xFFFFC1D9),
          Color(0xFFFF9EC4), Color(0xFFFF79B0));
    case Mood.motivated:
      return const _Palette(Color(0xFFFFF3E0), Color(0xFFFFE0B2),
          Color(0xFFFFCC80), Color(0xFFFFB74D));
    case Mood.relaxed:
      return const _Palette(Color(0xFFE0F7FA), Color(0xFFB2EBF2),
          Color(0xFF80DEEA), Color(0xFF4DD0E1));
  }
}
