import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/home_widget_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
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
    _inspiration = DailyInspiration.forToday(name, mood: Mood.calm);
    _load();
  }

  void _load() {
    _days = _garden.bloomDays;
    _variants = _days
        .map((d) =>
            FlowerVariant.fromSeed(d.year * 10000 + d.month * 100 + d.day))
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

  Future<void> _plant() async {
    final planted = await _garden.plantToday();
    if (!planted || !mounted) return;
    sl<HomeWidgetService>().refresh(); // el widget muestra la nueva flor
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

    return Stack(
        children: [
          const Positioned.fill(child: LuminousBackground()),
          Positioned.fill(
            child: ParticleLayer(
                mood: Mood.calm, controller: _burst, density: 0.6),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        context.wp(8), context.hp(4), context.wp(8), 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Menú',
                          icon: const Icon(Icons.menu_rounded,
                              color: _warmWhite),
                          onPressed: () =>
                              Scaffold.of(context).openDrawer(),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                    child: Column(
                      children: [
                        Text('Mi Jardín',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: context.sp(34).clamp(26, 40),
                              fontWeight: FontWeight.w700,
                              color: _warmWhite,
                              shadows: [
                                Shadow(
                                    color: _gold.withAlpha(120),
                                    blurRadius: 24)
                              ],
                            )),
                        SizedBox(height: context.hp(4)),
                        Text('Cada frase que lees hace florecer algo nuevo',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(13).clamp(11, 15),
                                color: _warmWhite.withAlpha(170))),
                        SizedBox(height: context.hp(14)),
                        Row(
                          children: [
                            _Stat(value: '${_days.length}', label: 'flores'),
                            SizedBox(width: context.wp(8)),
                            _Stat(
                                value: '${_garden.currentStreak}',
                                label: 'días seguidos'),
                            SizedBox(width: context.wp(8)),
                            _Stat(
                                value: '${_garden.weeksGrowing}',
                                label: 'semanas'),
                          ],
                        ),
                        SizedBox(height: context.hp(12)),
                        _QuoteCard(
                          inspiration: _inspiration,
                          bloomedToday: bloomedToday,
                          onRead: _plant,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.38,
                    child: _field(),
                  ),
                  SizedBox(height: context.bottomNavClearance),
                ],
              ),
            ),
          ),
        ],
    );
  }

  Widget _field() {
    if (_days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
      const spacing = 30.0;
      final n = _days.length;
      final width = math.max(c.maxWidth, n * spacing + 60);
      final flowerH = c.maxHeight;
      final flowerW = math.min(64.0, flowerH * 0.32);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // lo más reciente a la vista
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: width,
          height: flowerH,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _sway, _newGrowth]),
            builder: (context, _) {
              // Si hay pocas flores, se centran; si hay muchas, se reparten.
              final startX = (width - (n - 1) * spacing) / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Suelo luminoso
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 26,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF7CB342).withAlpha(0),
                            const Color(0xFF33691E).withAlpha(140),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < n; i++)
                    Positioned(
                      left: startX +
                          i * spacing -
                          flowerW / 2 +
                          (math.Random(i).nextDouble() - 0.5) * 10,
                      bottom: 6 + (i % 3) * 4,
                      width: flowerW,
                      height: flowerH - 10,
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
  });

  final DailyInspiration inspiration;
  final bool bloomedToday;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      dark: true,
      glow: !bloomedToday,
      padding: EdgeInsets.all(context.dp(18).clamp(14.0, 24.0)),
      child: Column(
        children: [
          Text('TU FRASE DE HOY ☀️',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(11).clamp(9, 13),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
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
                ? Text('Hoy ya floreció tu flor 🌼 Vuelve mañana',
                    key: const ValueKey('done'),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: context.sp(13).clamp(11, 15),
                        fontWeight: FontWeight.w700,
                        color: _gold))
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
                          BoxShadow(
                              color: _gold.withAlpha(110), blurRadius: 22)
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

