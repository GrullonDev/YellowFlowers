import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/core/home_widget_service.dart';
import 'package:yellow_flowers/core/notification_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/features/garden/widgets/share_helper.dart';
import 'package:yellow_flowers/features/music/widgets/ambient_sounds_sheet.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

/// "Mi Jardín": cada día que la usuaria lee su frase, florece una flor nueva.
class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> with TickerProviderStateMixin {
  final _garden = sl<GardenService>();
  final _burst = ParticleBurstController();

  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..forward();

  late final AnimationController _newGrowth = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200));

  late final AnimationController _sway =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  late List<DateTime> _days;
  late List<FlowerVariant> _variants;
  late final DailyInspiration _inspiration;
  bool _justPlanted = false;

  @override
  void initState() {
    super.initState();
    final name = sl<PersonalizationService>().getUserName() ?? '';
    final todayMood = _todayMoodIndex();
    final mood = _dailyMoodToMood(todayMood);
    _inspiration = DailyInspiration.forToday(name, mood: mood);
    _load();
  }

  static Mood _dailyMoodToMood(int? index) {
    // DailyMood: 0=happy, 1=calm, 2=strong, 3=reflective, 4=loving
    // Mood: joy, calm, passion
    switch (index) {
      case 0:
        return Mood.joy;
      case 1:
        return Mood.calm;
      case 2:
        return Mood.passion;
      case 3:
        return Mood.calm;
      case 4:
        return Mood.passion;
      default:
        return Mood.calm;
    }
  }

  int? _todayMoodIndex() {
    final prefs = sl<SharedPreferences>();
    final n = DateTime.now();
    final key =
        'mood_checkin_${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  static int? _moodIndexForDay(DateTime d) {
    final prefs = sl<SharedPreferences>();
    final key =
        'mood_checkin_${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  void _load() {
    _days = _garden.bloomDays;
    _variants = _days
        .map((d) => FlowerVariant.fromSeed(
              d.year * 10000 + d.month * 100 + d.day,
              moodIndex: _moodIndexForDay(d),
            ))
        .toList();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _newGrowth.dispose();
    _sway.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _shareQuote() {
    captureAndShare(
      context,
      card: _QuoteShareCard(inspiration: _inspiration),
      shareText: '✨ Descubre tu frase diaria en Amarillas 🌻',
    );
  }

  void _shareGarden() {
    final streak = _garden.currentStreak;
    if (streak < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A1A3A),
        content: Text(
          'Desbloquea esta opción alcanzando 5 días de constancia 🌻',
          style: GoogleFonts.plusJakartaSans(
              color: _warmWhite, fontWeight: FontWeight.w600),
        ),
      ));
      return;
    }
    captureAndShare(
      context,
      card: _GardenShareCard(
        totalFlowers: _days.length,
        streak: streak,
        weeks: _garden.weeksGrowing,
      ),
      shareText:
          '🌻 Mi jardín tiene ${_days.length} flores y llevo $streak días seguidos. ¡Cultiva el tuyo en Amarillas!',
    );
  }

  Future<void> _plant() async {
    final planted = await _garden.plantToday();
    if (!planted || !mounted) return;
    sl<HomeWidgetService>().refresh(); // el widget muestra la nueva flor
    // Racha activada: quita los recordatorios que faltaban hoy.
    sl<NotificationService>().reschedule();
    HapticFeedback.mediumImpact();
    setState(() {
      _justPlanted = true;
      _load();
    });
    await _newGrowth.forward(from: 0);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _burst.burst(origin: const Offset(0.5, 0.7), kind: ParticleKind.petal);
    final milestone = _milestoneMessage(_days.length);
    if (milestone != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A1A3A),
        content: Text(milestone,
            style: GoogleFonts.plusJakartaSans(
                color: _warmWhite, fontWeight: FontWeight.w700)),
      ));
    }
  }

  String? _milestoneMessage(int total) {
    switch (total) {
      case 1:
        return '¡Tu primera flor! Así empieza todo jardín 🌱';
      case 7:
        return '¡Una semana floreciendo! 🌼';
      case 30:
        return '¡30 flores! Tu jardín es un reflejo de tu constancia 🌻';
      case 100:
        return '¡100 flores! Eres pura primavera ✨';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bloomedToday = _garden.hasBloomedToday;
    final hPad = context.wp(20).clamp(14.0, 28.0);
    final navClearance = context.bottomNavClearance;

    return Stack(
      children: [
        const Positioned.fill(child: LuminousBackground()),
        Positioned.fill(
          child:
              ParticleLayer(mood: Mood.calm, controller: _burst, density: 0.6),
        ),
        // Ground + flowers anchored to the very bottom of the screen
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: context.screenHeight * 0.48,
          child: _field(navClearance),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    context.wp(8), context.hp(2), context.wp(8), 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Menú',
                      icon: const Icon(Icons.menu_rounded, color: _warmWhite),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Sonidos para leer',
                      icon: const Icon(Icons.headphones_rounded,
                          color: _warmWhite),
                      onPressed: () => showAmbientSounds(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                  child: Column(
                    children: [
                      Text('Mi Jardín',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: context.sp(32).clamp(24, 38),
                            fontWeight: FontWeight.w700,
                            color: _warmWhite,
                            shadows: [
                              Shadow(
                                  color: _gold.withAlpha(120), blurRadius: 24)
                            ],
                          )),
                      SizedBox(height: context.hp(2)),
                      Text('Cada frase que lees hace florecer algo nuevo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(12).clamp(10, 14),
                              color: _warmWhite.withAlpha(170))),
                      SizedBox(height: context.hp(6)),
                      Row(
                        children: [
                          _Stat(value: '${_days.length}', label: 'flores'),
                          SizedBox(width: context.wp(6)),
                          _Stat(
                              value: '${_garden.currentStreak}',
                              label: 'días seguidos'),
                          SizedBox(width: context.wp(6)),
                          _Stat(
                              value: '${_garden.weeksGrowing}',
                              label: 'semanas'),
                        ],
                      ),
                      SizedBox(height: context.hp(6)),
                      Flexible(
                        child: _QuoteCard(
                          inspiration: _inspiration,
                          bloomedToday: bloomedToday,
                          onRead: _plant,
                          onShareQuote: _shareQuote,
                          onShareGarden: _shareGarden,
                          gardenUnlocked: _garden.currentStreak >= 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(double navClearance) {
    if (_days.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: navClearance),
          child: Text(
            'Tu jardín está listo para su primera semilla 🌱\nLee tu frase de hoy para plantarla.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                color: _warmWhite.withAlpha(160), height: 1.5),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      const spacing = 36.0;
      final n = _days.length;
      final width = math.max(c.maxWidth, n * spacing + 80);
      final totalH = c.maxHeight;
      // Grass strip: thin band just above the nav bar
      final grassH = navClearance + context.hp(28).clamp(20.0, 36.0);
      // Flowers grow from the grass upward, filling most of the field
      final flowerH = (totalH - navClearance - 8).clamp(100.0, totalH * 0.92);
      final flowerW = (flowerH * 0.25).clamp(36.0, 90.0);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: width,
          height: totalH,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _sway, _newGrowth]),
            builder: (context, _) {
              final startX = (width - (n - 1) * spacing) / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Thin grass strip anchored at bottom, extending
                  // through the nav bar zone
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: grassH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF7CB342).withAlpha(0),
                            const Color(0xFF558B2F).withAlpha(100),
                            const Color(0xFF33691E).withAlpha(160),
                            const Color(0xFF1B5E20).withAlpha(200),
                          ],
                          stops: const [0.0, 0.25, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < n; i++)
                    Positioned(
                      left: startX +
                          i * spacing -
                          flowerW / 2 +
                          (math.Random(i).nextDouble() - 0.5) * 12,
                      bottom: navClearance + 2 + (i % 3) * 4,
                      width: flowerW,
                      height: flowerH,
                      child: GrowingFlower(
                        variant: _variants[i],
                        progress: _progressFor(i, n),
                        sway: math.sin(_sway.value * 2 * math.pi + i * 0.7),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  double _progressFor(int i, int n) {
    final isNew = _justPlanted && i == n - 1;
    if (isNew) return _newGrowth.value;
    final existing = _justPlanted ? n - 1 : n;
    // Cascada: cada flor arranca un poco después que la anterior
    final start = existing <= 1 ? 0.0 : (i / existing) * 0.45;
    final t = ((_entrance.value - start) / 0.55).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        dark: true,
        radius: context.dp(20).clamp(14.0, 24.0),
        padding: EdgeInsets.symmetric(
            vertical: context.hp(10).clamp(8.0, 14.0),
            horizontal: context.wp(6).clamp(4.0, 10.0)),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.playfairDisplay(
                    fontSize: context.sp(24).clamp(18, 28),
                    fontWeight: FontWeight.w700,
                    color: _gold)),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: context.sp(11).clamp(9, 13),
                    fontWeight: FontWeight.w600,
                    color: _warmWhite.withAlpha(170))),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.inspiration,
    required this.bloomedToday,
    required this.onRead,
    required this.onShareQuote,
    required this.onShareGarden,
    required this.gardenUnlocked,
  });

  final DailyInspiration inspiration;
  final bool bloomedToday;
  final VoidCallback onRead;
  final VoidCallback onShareQuote;
  final VoidCallback onShareGarden;
  final bool gardenUnlocked;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      dark: true,
      glow: !bloomedToday,
      padding: EdgeInsets.all(context.dp(18).clamp(14.0, 24.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text('TU FRASE DE HOY ☀️',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: context.sp(11).clamp(9, 13),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: _gold)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onShareQuote,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withAlpha(30),
                        border: Border.all(color: _gold.withAlpha(60)),
                      ),
                      child: Icon(Icons.share_rounded,
                          color: _gold, size: context.dp(16).clamp(14.0, 20.0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(8)),
          Text(inspiration.greeting,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(13).clamp(11, 15),
                  fontWeight: FontWeight.w600,
                  color: _warmWhite.withAlpha(200))),
          SizedBox(height: context.hp(8)),
          Text('”${inspiration.quote}”',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                  fontSize: context.sp(17).clamp(14, 20),
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: _warmWhite)),
          if (inspiration.author != null)
            Padding(
              padding: EdgeInsets.only(top: context.hp(5)),
              child: Text('— ${inspiration.author}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: context.sp(12).clamp(10, 14),
                      fontWeight: FontWeight.w700,
                      color: _gold.withAlpha(200))),
            ),
          SizedBox(height: context.hp(12)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: bloomedToday
                ? Column(
                    key: const ValueKey('done'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hoy ya floreció tu flor 🌼',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(13).clamp(11, 15),
                              fontWeight: FontWeight.w700,
                              color: _gold)),
                      SizedBox(height: context.hp(8)),
                      GestureDetector(
                        onTap: onShareGarden,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.wp(14).clamp(10.0, 20.0),
                              vertical: context.hp(8).clamp(6.0, 12.0)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                context.dp(16).clamp(12.0, 20.0)),
                            color: gardenUnlocked
                                ? _gold.withAlpha(30)
                                : Colors.white.withAlpha(10),
                            border: Border.all(
                              color: gardenUnlocked
                                  ? _gold.withAlpha(100)
                                  : Colors.white.withAlpha(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gardenUnlocked
                                    ? Icons.park_rounded
                                    : Icons.lock_rounded,
                                color: gardenUnlocked
                                    ? _gold
                                    : _warmWhite.withAlpha(100),
                                size: context.dp(16).clamp(14.0, 20.0),
                              ),
                              SizedBox(width: context.wp(4)),
                              Text(
                                gardenUnlocked
                                    ? 'Compartir mi jardín 🌻'
                                    : 'Alcanza 5 días para compartir',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(11).clamp(9, 13),
                                  fontWeight: FontWeight.w700,
                                  color: gardenUnlocked
                                      ? _gold
                                      : _warmWhite.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    key: const ValueKey('plant'),
                    onTap: onRead,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.wp(24).clamp(18.0, 30.0),
                          vertical: context.hp(12).clamp(10.0, 16.0)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            context.dp(18).clamp(14.0, 22.0)),
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFFB300)]),
                        boxShadow: [
                          BoxShadow(color: _gold.withAlpha(110), blurRadius: 22)
                        ],
                      ),
                      child: Text('La leí · Plantar mi flor 🌱',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(14).clamp(12, 16),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3E2723))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Share cards (rendered offscreen for image export) ───

class _QuoteShareCard extends StatelessWidget {
  const _QuoteShareCard({required this.inspiration});
  final DailyInspiration inspiration;

  static const _bg = Color(0xFF0B0820);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _gold.withAlpha(80), width: 3),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌻', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text('FRASE DEL DÍA',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: _gold)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _gold.withAlpha(40)),
            ),
            child: Column(
              children: [
                Text(
                  '”${inspiration.quote}”',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: _warmWhite,
                  ),
                ),
                if (inspiration.author != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '— ${inspiration.author}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          Container(width: 60, height: 1.5, color: _gold.withAlpha(60)),
          const SizedBox(height: 24),
          Text(
            'Descubre tu frase diaria en Amarillas 🌻',
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

class _GardenShareCard extends StatelessWidget {
  const _GardenShareCard({
    required this.totalFlowers,
    required this.streak,
    required this.weeks,
  });
  final int totalFlowers, streak, weeks;

  static const _bg = Color(0xFF0B0820);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _gold.withAlpha(80), width: 3),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌻🌼🌸', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 24),
          Text('MI JARDÍN',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: _gold)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _shareStatColumn('$totalFlowers', 'flores'),
              Container(width: 1.5, height: 60, color: _gold.withAlpha(40)),
              _shareStatColumn('$streak', 'días seguidos'),
              Container(width: 1.5, height: 60, color: _gold.withAlpha(40)),
              _shareStatColumn('$weeks', 'semanas'),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _gold.withAlpha(40)),
            ),
            child: Text(
              'Cada día leo una frase y planto una flor.\n¡Ya llevo $streak días sin fallar!',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
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
            'Cultiva tu propio jardín en Amarillas 🌻',
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

  Widget _shareStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: 42, fontWeight: FontWeight.w700, color: _gold)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _warmWhite.withAlpha(170))),
      ],
    );
  }
}
