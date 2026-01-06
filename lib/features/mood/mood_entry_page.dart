import 'package:flutter/material.dart';
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
        return WillPopScope(
          onWillPop: () async => false, // Bloquear gesto/back: es pantalla inicial del día
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false, // Oculta flecha de back
              title: const Text('¿Cómo te sientes hoy?'),
            ),
            body: AnimatedBackground(
              topColorBegin: palette.topStart,
              topColorEnd: palette.topEnd,
              bottomColorBegin: palette.bottomStart,
              bottomColorEnd: palette.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _MoodCard(
                      label: 'Alegre 💛',
                      description: 'Energía positiva y sonrisas',
                      color: Colors.amber,
                      onTap: () async {
                        await moodController.setMood(Mood.happy);
                        if (context.mounted) Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(height: 12),
                    _MoodCard(
                      label: 'Nostálgica 🌙',
                      description: 'Recuerdos y momentos',
                      color: Colors.indigoAccent,
                      onTap: () async {
                        await moodController.setMood(Mood.nostalgic);
                        if (context.mounted) Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(height: 12),
                    _MoodCard(
                      label: 'Enamorada 💖',
                      description: 'Ternura y romanticismo',
                      color: Colors.pinkAccent,
                      onTap: () async {
                        await moodController.setMood(Mood.romantic);
                        if (context.mounted) Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(height: 12),
                    _MoodCard(
                      label: 'Motivada ✨',
                      description: 'Fuerza y enfoque',
                      color: Colors.orangeAccent,
                      onTap: () async {
                        await moodController.setMood(Mood.motivated);
                        if (context.mounted) Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Sin botón "Continuar": aplicar y cerrar al tocar una opción
                  ],
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
    required this.description,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
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
      return const _Palette(Color(0xFFFFF7C2), Color(0xFFFFE8A3), Color(0xFFFFD3B6), Color(0xFFFFB347));
    case Mood.nostalgic:
      return const _Palette(Color(0xFFD1C4E9), Color(0xFFB39DDB), Color(0xFF9575CD), Color(0xFF7E57C2));
    case Mood.romantic:
      return const _Palette(Color(0xFFFFE4EC), Color(0xFFFFC1D9), Color(0xFFFF9EC4), Color(0xFFFF79B0));
    case Mood.motivated:
      return const _Palette(Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFFB74D));
    case Mood.relaxed:
      return const _Palette(Color(0xFFE0F7FA), Color(0xFFB2EBF2), Color(0xFF80DEEA), Color(0xFF4DD0E1));
  }
}
