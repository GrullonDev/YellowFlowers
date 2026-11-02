import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/core/user_gender.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/features/garden/models/daily_mood.dart';
import 'package:yellow_flowers/features/garden/widgets/breathing_sheet.dart';
import 'package:yellow_flowers/features/garden/widgets/share_helper.dart';
import 'package:yellow_flowers/features/mandala/pages/mandala_gallery_page.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

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
      _selected = DailyMoodX.fromIndex(int.tryParse(raw));
      _saved = _selected != null;
    }
  }

  void _shareMood(DailyMood mood, String name) {
    final meta = mood.info;
    final message = mood.messageFor(name);
    captureAndShare(
      context,
      card: _MoodShareCard(
        emoji: meta.responseEmoji,
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
    final personalization = sl<PersonalizationService>();
    final name = personalization.getUserName() ?? personalization.defaultGreetingName;
    final gender = personalization.getUserGender();
    final availableMoods = moodsForGender(gender);
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
                  Text('Hola $name, aquí todo lo que sientes es válido',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(13).clamp(11, 15),
                          color: _warmWhite.withAlpha(170))),
                  SizedBox(height: context.hp(16)),
                  _MoodGroup(
                    title: 'Hoy me siento bien',
                    moods: availableMoods.where((m) => m.isBright).toList(),
                    selected: _selected,
                    onTap: _select,
                  ),
                  SizedBox(height: context.hp(14)),
                  _MoodGroup(
                    title: 'Hoy me cuesta un poco',
                    moods: availableMoods.where((m) => !m.isBright).toList(),
                    selected: _selected,
                    onTap: _select,
                  ),
                  if (_saved && _selected != null) ...[
                    SizedBox(height: context.hp(16)),
                    GlassCard(
                      dark: true,
                      glow: true,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => _shareMood(_selected!, name),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _gold.withAlpha(30),
                                  border:
                                      Border.all(color: _gold.withAlpha(60)),
                                ),
                                child: Icon(Icons.share_rounded,
                                    color: _gold,
                                    size: context.dp(16).clamp(14.0, 20.0)),
                              ),
                            ),
                          ),
                          Text(_selected!.info.responseEmoji,
                              style: TextStyle(
                                  fontSize: context.sp(36).clamp(28, 44))),
                          SizedBox(height: context.hp(12)),
                          Text(_selected!.messageFor(name),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: context.sp(17).clamp(14, 20),
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                  color: _warmWhite)),
                        ],
                      ),
                    ),
                    if (_selected!.info.needsComfort) ...[
                      SizedBox(height: context.hp(12)),
                      _ComfortCard(mood: _selected!),
                    ],
                    SizedBox(height: context.hp(12)),
                    _MoodHistory(),
                  ],
                  SizedBox(height: context.hp(12)),
                  const _MandalaInvite(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodGroup extends StatelessWidget {
  const _MoodGroup({
    required this.title,
    required this.moods,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final List<DailyMood> moods;
  final DailyMood? selected;
  final ValueChanged<DailyMood> onTap;

  @override
  Widget build(BuildContext context) {
    final gap = context.wp(10).clamp(8.0, 12.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: context.hp(8)),
          child: Text(title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(10).clamp(8, 12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
        ),
        LayoutBuilder(
          builder: (_, c) {
            final w = (c.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final m in moods)
                  SizedBox(
                    width: w,
                    child: _MoodTile(
                        mood: m,
                        selected: selected == m,
                        onTap: () => onTap(m)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });
  final DailyMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = mood.info;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
            horizontal: context.wp(12).clamp(10.0, 16.0),
            vertical: context.hp(12).clamp(9.0, 16.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.dp(18).clamp(14.0, 22.0)),
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
                style: TextStyle(fontSize: context.sp(24).clamp(20, 30))),
            SizedBox(width: context.wp(8).clamp(6.0, 12.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(14).clamp(12, 17),
                          fontWeight: FontWeight.w700,
                          color: selected ? info.color : _warmWhite)),
                  Text(info.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(10).clamp(9, 12),
                          height: 1.25,
                          color: _warmWhite.withAlpha(140))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gestos para los días difíciles: respirar, escuchar música o colorear.
class _ComfortCard extends StatelessWidget {
  const _ComfortCard({required this.mood});
  final DailyMood mood;

  @override
  Widget build(BuildContext context) {
    final color = mood.info.color;
    return GlassCard(
      dark: true,
      radius: context.dp(20).clamp(14.0, 24.0),
      padding: EdgeInsets.all(context.wp(16).clamp(12.0, 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UN PEQUEÑO GESTO PARA TI',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(10).clamp(8, 12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
          SizedBox(height: context.hp(10)),
          for (final action in mood.info.comfort)
            _ComfortButton(action: action, color: color),
          SizedBox(height: context.hp(6)),
          Text(
            'Si este sentimiento no se va o se vuelve muy pesado, hablar con '
            'alguien de confianza o con un profesional también es quererte.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: context.sp(11).clamp(9, 13),
                height: 1.4,
                color: _warmWhite.withAlpha(130)),
          ),
        ],
      ),
    );
  }
}

class _ComfortButton extends StatelessWidget {
  const _ComfortButton({required this.action, required this.color});
  final ComfortAction action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (action) {
      ComfortAction.breathe => (
          Icons.air_rounded,
          'Respira conmigo',
          'Un minuto para soltar la tensión'
        ),
      ComfortAction.mandala => (
          Icons.palette_rounded,
          'Colorea un mandala',
          'Pinta despacio y deja que tu mente descanse'
        ),
      ComfortAction.music => (
          Icons.headphones_rounded,
          'Escucha algo bonito',
          'Música para acompañarte'
        ),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: context.hp(8)),
      child: Material(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            switch (action) {
              case ComfortAction.breathe:
                showBreathingSheet(context, color: color);
              case ComfortAction.mandala:
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MandalaGalleryPage()));
              case ComfortAction.music:
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MusicPage()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _warmWhite)),
                      Text(subtitle,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: _warmWhite.withAlpha(150))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: _warmWhite.withAlpha(90)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Acceso a los mandalas, visible en cualquier día.
class _MandalaInvite extends StatelessWidget {
  const _MandalaInvite();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const MandalaGalleryPage())),
      child: GlassCard(
        dark: true,
        radius: context.dp(20).clamp(14.0, 24.0),
        padding: EdgeInsets.all(context.wp(16).clamp(12.0, 20.0)),
        child: Row(
          children: [
            Text('🎨',
                style: TextStyle(fontSize: context.sp(28).clamp(22, 34))),
            SizedBox(width: context.wp(12).clamp(8.0, 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mandalas para colorear',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(15).clamp(13, 18),
                          fontWeight: FontWeight.w700,
                          color: _warmWhite)),
                  Text('Un rato creativo para calmar la mente',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(11).clamp(9, 13),
                          color: _warmWhite.withAlpha(150))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _gold),
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
              final mood =
                  DailyMoodX.fromIndex(raw == null ? null : int.tryParse(raw));
              final meta = mood?.info;
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
