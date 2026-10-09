import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/features/garden/widgets/share_helper.dart';
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

  void _shareMood(DailyMood mood, String name) {
    final meta = _moodMeta(mood);
    final message = _responseMessage(mood, name);
    captureAndShare(
      context,
      card: _MoodShareCard(
        emoji: _responseEmoji(mood),
        moodLabel: meta.label,
        moodColor: meta.color,
        message: message,
      ),
      shareText:
          '${meta.emoji} Mi momento de hoy: ${meta.label}. Descubre el tuyo en Amarillas 🌻',
    );
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
    final hPad = context.wp(20).clamp(14.0, 28.0);

    return Stack(
      children: [
        const Positioned.fill(child: LuminousBackground()),
        SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  hPad, context.hp(16), hPad, context.bottomNavClearance),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text('¿Cómo te sientes hoy?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: context.sp(28).clamp(22, 34),
                        fontWeight: FontWeight.w700,
                        color: _warmWhite,
                        shadows: [
                          Shadow(color: _gold.withAlpha(120), blurRadius: 24)
                        ],
                      )),
                  SizedBox(height: context.hp(6)),
                  Text('Hola $name, elige tu estado de ánimo',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(13).clamp(11, 15),
                          color: _warmWhite.withAlpha(170))),
                  SizedBox(height: context.hp(16)),
                  ...DailyMood.values.map((m) => Padding(
                        padding: EdgeInsets.only(bottom: context.hp(6)),
                        child: _MoodOption(
                          mood: m,
                          selected: _selected == m,
                          onTap: () => _select(m),
                        ),
                      )),
                  if (_saved && _selected != null) ...[
                    SizedBox(height: context.hp(16)),
                    GlassCard(
                      dark: true,
                      glow: true,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Semantics(
                              button: true,
                              label: 'Compartir mi estado de ánimo',
                              child: GestureDetector(
                                onTap: () => _shareMood(_selected!, name),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _gold.withAlpha(30),
                                    border: Border.all(
                                        color: _gold.withAlpha(60)),
                                  ),
                                  child: Icon(Icons.share_rounded,
                                      color: _gold,
                                      size: context.dp(16).clamp(14.0, 20.0)),
                                ),
                              ),
                            ),
                          ),
                          Text(_responseEmoji(_selected!),
                              style: TextStyle(
                                  fontSize: context.sp(36).clamp(28, 44))),
                          SizedBox(height: context.hp(12)),
                          Text(_responseMessage(_selected!, name),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: context.sp(17).clamp(14, 20),
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: _warmWhite)),
                        ],
                      ),
                    ),
                    SizedBox(height: context.hp(12)),
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
    return Semantics(
      button: true,
      selected: selected,
      label: info.label,
      child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
            horizontal: context.wp(18).clamp(12.0, 22.0),
            vertical: context.hp(14).clamp(10.0, 18.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.dp(20).clamp(14.0, 24.0)),
          color:
              selected ? info.color.withAlpha(50) : Colors.white.withAlpha(15),
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
            Text(info.emoji,
                style: TextStyle(fontSize: context.sp(28).clamp(22, 34))),
            SizedBox(width: context.wp(14).clamp(10.0, 18.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(16).clamp(13, 19),
                          fontWeight: FontWeight.w700,
                          color: selected ? info.color : _warmWhite)),
                  Text(info.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(12).clamp(10, 14),
                          color: _warmWhite.withAlpha(140))),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: info.color, size: context.dp(24).clamp(20.0, 28.0)),
          ],
        ),
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
    final circleSize = context.dp(32).clamp(26.0, 40.0);

    return GlassCard(
      dark: true,
      radius: context.dp(20).clamp(14.0, 24.0),
      padding: EdgeInsets.symmetric(
          vertical: context.hp(14).clamp(10.0, 18.0),
          horizontal: context.wp(12).clamp(8.0, 16.0)),
      child: Column(
        children: [
          Text('TU SEMANA',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(10).clamp(8, 12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
          SizedBox(height: context.hp(10)),
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
                          fontSize: context.sp(10).clamp(8, 12),
                          fontWeight: FontWeight.w700,
                          color: _warmWhite.withAlpha(isToday ? 255 : 100))),
                  SizedBox(height: context.hp(6)),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: meta?.color.withAlpha(40) ??
                          Colors.white.withAlpha(10),
                      border:
                          isToday ? Border.all(color: _gold, width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      meta?.emoji ?? '·',
                      style: TextStyle(
                          fontSize:
                              context.sp(meta != null ? 16 : 12).clamp(10, 20)),
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

class _MoodShareCard extends StatelessWidget {
  const _MoodShareCard({
    required this.emoji,
    required this.moodLabel,
    required this.moodColor,
    required this.message,
  });
  final String emoji, moodLabel, message;
  final Color moodColor;

  static const _bg = Color(0xFF0B0820);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: moodColor.withAlpha(80), width: 3),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(moodLabel.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: moodColor)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: moodColor.withAlpha(15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: moodColor.withAlpha(40)),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: _warmWhite,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Container(width: 60, height: 1.5, color: _gold.withAlpha(60)),
          const SizedBox(height: 24),
          Text(
            'Descubre cómo te sientes hoy en Amarillas 🌻',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _warmWhite.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }
}
