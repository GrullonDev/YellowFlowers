import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/core/home_widget_service.dart';
import 'package:yellow_flowers/core/notification_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_onboarding.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/features/messages/pages/special_messages_page.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/moments_gallery_page.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/features/music/widgets/ambient_sounds_sheet.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';
import 'package:yellow_flowers/features/onboarding/pages/storytelling_onboarding.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
  bool _showOnboarding = false;
  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    final name = sl<PersonalizationService>().getUserName() ?? '';
    _inspiration = DailyInspiration.forToday(name, mood: Mood.calm);
    _load();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = sl<SharedPreferences>();
    final seen = prefs.getBool('seen_premium_onboarding') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !seen;
        _onboardingChecked = true;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('seen_premium_onboarding', true);
    if (mounted) setState(() => _showOnboarding = false);
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
    if (!_onboardingChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0820),
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }
    if (_showOnboarding) {
      return StorytellingOnboarding(onComplete: _completeOnboarding);
    }

    final bloomedToday = _garden.hasBloomedToday;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0B0820),
      extendBodyBehindAppBar: true,
      drawer: _GardenDrawer(notificationService: sl<NotificationService>()),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmWhite),
        leading: IconButton(
          tooltip: 'Menú',
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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

class _GardenDrawer extends StatefulWidget {
  const _GardenDrawer({required this.notificationService});
  final NotificationService notificationService;

  @override
  State<_GardenDrawer> createState() => _GardenDrawerState();
}

class _GardenDrawerState extends State<_GardenDrawer> {
  late bool _notificationsOn;

  @override
  void initState() {
    super.initState();
    _notificationsOn = widget.notificationService.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final name = sl<PersonalizationService>().getUserName() ?? 'hermosa';
    return Drawer(
      backgroundColor: const Color(0xFF1A1030),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, $name',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _warmWhite)),
                  const SizedBox(height: 4),
                  Text('Tu espacio de calma y flores',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: _warmWhite.withAlpha(150))),
                ],
              ),
            ),
            const Divider(color: Color(0x33FFD54F), indent: 20, endIndent: 20),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.local_florist,
              label: 'Flores Amarillas',
              color: const Color(0xFFFFB300),
              onTap: () => _navigate(context, const FlowerOnboardingPage()),
            ),
            _DrawerTile(
              icon: Icons.photo_library_rounded,
              label: 'Galería de Momentos',
              color: const Color(0xFF43A047),
              onTap: () => _navigate(context, const MomentsGalleryPage()),
            ),
            _DrawerTile(
              icon: Icons.message_rounded,
              label: 'Mensajes Especiales',
              color: const Color(0xFFE91E8C),
              onTap: () => _navigate(context, const SpecialMessagesPage()),
            ),
            _DrawerTile(
              icon: Icons.headphones_rounded,
              label: 'Tu Música',
              color: const Color(0xFF7E57C2),
              onTap: () => _navigate(context, const MusicPage()),
            ),
            _DrawerTile(
              icon: Icons.spa_rounded,
              label: 'Mi Ciclo',
              color: const Color(0xFF0097A7),
              onTap: () => _navigate(context, const CycleMusicPage()),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: _gold.withAlpha(180), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Recordatorio diario',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, color: _warmWhite.withAlpha(200))),
                  ),
                  Switch.adaptive(
                    value: _notificationsOn,
                    activeTrackColor: _gold,
                    onChanged: (v) {
                      setState(() => _notificationsOn = v);
                      widget.notificationService.setEnabled(v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _warmWhite)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: _warmWhite.withAlpha(60), size: 20),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
