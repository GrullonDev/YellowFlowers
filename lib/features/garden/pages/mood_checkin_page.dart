import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

enum DailyMood {
  happy,
  calm,
  strong,
  reflective,
  loving,
}

class MoodCheckinPage extends StatefulWidget {
  const MoodCheckinPage({super.key});

  @override
  State<MoodCheckinPage> createState() => _MoodCheckinPageState();
}

class _MoodCheckinPageState extends State<MoodCheckinPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))
    ..forward();

  DailyMood? _selected;
  bool _saved = false;

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    final prefs = sl<SharedPreferences>();
    final raw = prefs.getString('mood_checkin_$_todayKey');
    if (raw != null) {
      final idx = int.tryParse(raw);
      if (idx != null && idx < DailyMood.values.length) {
        _selected = DailyMood.values[idx];
        _saved = true;
      }
    }
  }

  Future<void> _select(DailyMood mood) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = mood;
      _saved = true;
    });
    final prefs = sl<SharedPreferences>();
    await prefs.setString('mood_checkin_$_todayKey', mood.index.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = sl<PersonalizationService>().getUserName() ?? 'hermosa';
    return Stack(
      children: [
        const Positioned.fill(child: LuminousBackground()),
        SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text('¿Cómo te sientes hoy?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _warmWhite,
                        shadows: [
                          Shadow(color: _gold.withAlpha(120), blurRadius: 24)
                        ],
                      )),
                  const SizedBox(height: 6),
                  Text('Hola $name, elige tu estado de ánimo',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: _warmWhite.withAlpha(170))),
                  const SizedBox(height: 28),
                  ...DailyMood.values.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MoodOption(
                          mood: m,
                          selected: _selected == m,
                          onTap: () => _select(m),
                        ),
                      )),
                  if (_saved && _selected != null) ...[
                    const SizedBox(height: 20),
                    GlassCard(
                      dark: true,
                      glow: true,
                      child: Column(
                        children: [
                          Text(_responseEmoji(_selected!),
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          Text(_responseMessage(_selected!, name),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: _warmWhite)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MoodHistory(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });
  final DailyMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = _moodMeta(mood);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? info.color.withAlpha(50)
              : Colors.white.withAlpha(15),
          border: Border.all(
            color: selected ? info.color : Colors.white.withAlpha(25),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: info.color.withAlpha(40), blurRadius: 20)]
              : null,
        ),
        child: Row(
          children: [
            Text(info.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected ? info.color : _warmWhite)),
                  Text(info.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _warmWhite.withAlpha(140))),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: info.color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _MoodHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = sl<SharedPreferences>();
    final now = DateTime.now();
    final days = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final weekday = now.weekday;

    return GlassCard(
      dark: true,
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          Text('TU SEMANA',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final dayOffset = i - (weekday - 1);
              final date = now.add(Duration(days: dayOffset));
              final key =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final raw = prefs.getString('mood_checkin_$key');
              DailyMood? mood;
              if (raw != null) {
                final idx = int.tryParse(raw);
                if (idx != null && idx < DailyMood.values.length) {
                  mood = DailyMood.values[idx];
                }
              }
              final meta = mood != null ? _moodMeta(mood) : null;
              final isToday = dayOffset == 0;
              return Column(
                children: [
                  Text(days[i],
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _warmWhite.withAlpha(isToday ? 255 : 100))),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: meta?.color.withAlpha(40) ??
                          Colors.white.withAlpha(10),
                      border: isToday
                          ? Border.all(color: _gold, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      meta?.emoji ?? '·',
                      style: TextStyle(fontSize: meta != null ? 16 : 12),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MoodMeta {
  const _MoodMeta(this.emoji, this.label, this.subtitle, this.color);
  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
}

_MoodMeta _moodMeta(DailyMood mood) {
  switch (mood) {
    case DailyMood.happy:
      return const _MoodMeta(
          '😊', 'Feliz', 'Me siento alegre y con energía', Color(0xFFFFB300));
    case DailyMood.calm:
      return const _MoodMeta(
          '🌿', 'Tranquila', 'Estoy en paz y relajada', Color(0xFF43A047));
    case DailyMood.strong:
      return const _MoodMeta(
          '💪', 'Fuerte', 'Me siento valiente y decidida', Color(0xFFF57C00));
    case DailyMood.reflective:
      return const _MoodMeta(
          '🌙', 'Reflexiva', 'Necesito un momento conmigo', Color(0xFF7E57C2));
    case DailyMood.loving:
      return const _MoodMeta(
          '💖', 'Enamorada', 'El amor llena mi día', Color(0xFFE91E8C));
  }
}

String _responseEmoji(DailyMood mood) {
  switch (mood) {
    case DailyMood.happy:
      return '🌻';
    case DailyMood.calm:
      return '🍃';
    case DailyMood.strong:
      return '🔥';
    case DailyMood.reflective:
      return '✨';
    case DailyMood.loving:
      return '🌹';
  }
}

String _responseMessage(DailyMood mood, String name) {
  switch (mood) {
    case DailyMood.happy:
      return '¡Qué bonito, $name! Tu alegría ilumina todo a tu alrededor. Hoy tu jardín florecerá con colores brillantes.';
    case DailyMood.calm:
      return 'Qué paz, $name. Hoy es un día perfecto para respirar profundo y disfrutar cada momento con calma.';
    case DailyMood.strong:
      return '¡Así se siente, $name! Esa fuerza interior es lo que te hace imparable. Hoy nada te detiene.';
    case DailyMood.reflective:
      return 'Está bien sentirse así, $name. Los momentos de reflexión nos ayudan a crecer. Tu jardín te abraza.';
    case DailyMood.loving:
      return 'El amor te rodea, $name. Hoy tu jardín floreció con un brillo especial, justo como tú.';
  }
}
