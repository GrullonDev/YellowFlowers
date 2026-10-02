import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/home_widget_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
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

  /// Las flores existentes crecen en cascada al entrar.
  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..forward();

  /// Crecimiento de la flor recién plantada.
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmWhite),
        // Abierta desde el widget (sin historial): ir al inicio
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                tooltip: 'Inicio',
                icon: const Icon(Icons.home_rounded),
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomePage())),
              ),
        actions: [
          IconButton(
            tooltip: 'Sonidos para leer',
            icon: const Icon(Icons.headphones_rounded),
            onPressed: () => showAmbientSounds(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: LuminousBackground()),
          Positioned.fill(
            child: ParticleLayer(
                mood: Mood.calm, controller: _burst, density: 0.6),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    children: [
                      Text('Mi Jardín',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: _warmWhite,
                            shadows: [
                              Shadow(
                                  color: _gold.withAlpha(120), blurRadius: 24)
                            ],
                          )),
                      const SizedBox(height: 4),
                      Text('Cada frase que lees hace florecer algo nuevo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: _warmWhite.withAlpha(170))),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _Stat(value: '${_days.length}', label: 'flores'),
                          const SizedBox(width: 10),
                          _Stat(
                              value: '${_garden.currentStreak}',
                              label: 'días seguidos'),
                          const SizedBox(width: 10),
                          _Stat(
                              value: '${_garden.weeksGrowing}',
                              label: 'semanas'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _QuoteCard(
                        inspiration: _inspiration,
                        bloomedToday: bloomedToday,
                        onRead: _plant,
                      ),
                    ],
                  ),
                ),
                Expanded(child: _field()),
              ],
            ),
          ),
        ],
      ),
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
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24, fontWeight: FontWeight.w700, color: _gold)),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
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
      child: Column(
        children: [
          Text('TU FRASE DE HOY ☀️',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
          const SizedBox(height: 10),
          Text(inspiration.greeting,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _warmWhite.withAlpha(200))),
          const SizedBox(height: 10),
          Text('“${inspiration.quote}”',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: _warmWhite)),
          if (inspiration.author != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('— ${inspiration.author}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _gold.withAlpha(200))),
            ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: bloomedToday
                ? Text('Hoy ya floreció tu flor 🌼 Vuelve mañana',
                    key: const ValueKey('done'),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _gold))
                : GestureDetector(
                    key: const ValueKey('plant'),
                    onTap: onRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFFB300)]),
                        boxShadow: [
                          BoxShadow(
                              color: _gold.withAlpha(110), blurRadius: 22)
                        ],
                      ),
                      child: Text('La leí · Plantar mi flor 🌱',
                          style: GoogleFonts.plusJakartaSans(
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
