import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/share_origin.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/default_messages.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/memory_box.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/background_layer.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/utils/constants.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';
import 'package:yellow_flowers/widgets/share_canvas.dart';

class FlowerResultPage extends StatefulWidget {
  const FlowerResultPage({
    super.key,
    required this.sender,
    required this.recipient,
    this.dedication,
    required this.theme,
    required this.mood,
  });

  final String sender;
  final String recipient;
  final String? dedication;
  final FlowerTheme theme;
  final Mood mood;

  @override
  State<FlowerResultPage> createState() => _FlowerResultPageState();
}

class _FlowerResultPageState extends State<FlowerResultPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _growController;
  late final AnimationController _bgController;
  late final AnimationController _petalController;
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey _shareBoundaryKey = GlobalKey();

  late final List<PetalSeed> _petalSeeds;
  late final String _finalDedication;
  late final DailyInspiration _inspiration;
  final ParticleBurstController _burst = ParticleBurstController();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _growController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4200));
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat(reverse: true);
    _petalController =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..repeat();

    final name = sl<PersonalizationService>().getUserName();
    _finalDedication =
        (widget.dedication == null || widget.dedication!.trim().isEmpty)
            ? DefaultMessages.getRandom(name)
            : widget.dedication!;

    _inspiration =
        DailyInspiration.forToday(widget.recipient, mood: widget.mood);

    _initPetalSeeds();
    // 1) Las flores crecen desde el suelo; 2) aparecen las tarjetas;
    // 3) ráfaga de bienvenida cuando el ramo termina de abrirse.
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) _entranceController.forward();
      });
      await _growController.forward();
      if (mounted) {
        _burst.burst(
            origin: const Offset(0.5, 0.25),
            kind: widget.mood == Mood.passion
                ? ParticleKind.heart
                : ParticleKind.petal);
      }
    });
  }

  void _initPetalSeeds() {
    final rnd = math.Random();
    _petalSeeds = List.generate(20, (i) {
      return PetalSeed(
        startX: rnd.nextDouble(),
        startY: rnd.nextDouble(),
        swayAmp: 25 + rnd.nextDouble() * 30,
        swayFreq: 0.4 + rnd.nextDouble() * 0.6,
        size: 12 + rnd.nextDouble() * 14,
        rotationSpeed: 0.2 + rnd.nextDouble() * 0.4,
        phase: rnd.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _growController.dispose();
    _bgController.dispose();
    _petalController.dispose();
    _burst.dispose();
    super.dispose();
  }

  /// Captures the on-screen "VISTA PREVIA" card exactly as shown, so what
  /// gets shared always matches what the user just previewed. The boundary
  /// is scaled up to [kShareImageWidth] on export regardless of the device's
  /// actual screen size, since it's displayed on screen at a smaller,
  /// device-dependent size via [AspectRatio] + [FittedBox].
  Future<void> _exportImage() async {
    final origin = shareOrigin(context);
    try {
      final boundary = _shareBoundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final pixelRatio = kShareImageWidth / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
              '${directory.path}/gift_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await imagePath.writeAsBytes(pngBytes);

      await SharePlus.instance.share(ShareParams(
          files: [XFile(imagePath.path)],
          text: '✨ Un momento cultivado para ti: ${widget.recipient} 💛',
          sharePositionOrigin: origin));
    } catch (e) {
      debugPrint('Export Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No pudimos compartir tu flor. Intenta de nuevo.')),
        );
      }
    }
  }

  /// Si se abrió desde un enlace (sin historial), regresa al inicio.
  void _goBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  void _openMemoryBox() {
    showMemoryBox(
      context,
      recipient: widget.recipient,
      onEnvelopeOpened: () => _burst.burst(origin: const Offset(0.5, 0.35)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = PremiumDesign.isDarkMode(context);
    final iconColor = dark ? const Color(0xFFFFF8E1) : PremiumDesign.softText;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B0820) : null,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: iconColor),
            onPressed: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.popUntil((route) => route.isFirst);
              } else {
                _goBack();
              }
            },
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _bgController,
            _petalController,
            _entranceController,
            _growController
          ]),
          builder: (context, _) => Stack(
            children: [
              if (dark)
                const Positioned.fill(child: LuminousBackground())
              else
                BackgroundLayer(
                  topColor: widget.mood == Mood.passion
                      ? const Color(0xFFFFCCBC)
                      : widget.mood == Mood.calm
                          ? const Color(0xFFD1C4E9)
                          : PremiumDesign.mesh1,
                  bottomColor: Colors.white,
                  bgAnimation: _bgController,
                  petalAnimation: _petalController,
                  petalSeeds: _petalSeeds,
                ),
              ParticleLayer(mood: widget.mood, controller: _burst),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                  child: Column(
                    children: [
                      const SizedBox(height: PremiumDesign.s16),
                      _GrowingBouquet(
                        theme: widget.theme,
                        progress: _growController.value,
                        sway: math.sin(_petalController.value * 8 * math.pi),
                      ),
                      const SizedBox(height: PremiumDesign.s16),
                      _StaggeredItem(
                        index: 1,
                        controller: _entranceController,
                        child: Column(
                          children: [
                            Text('VISTA PREVIA',
                                style: PremiumDesign.sansLabel
                                    .copyWith(color: iconColor)),
                            const SizedBox(height: PremiumDesign.s12),
                            AspectRatio(
                              aspectRatio: kShareImageWidth / kShareImageHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: RepaintBoundary(
                                  key: _shareBoundaryKey,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: ShareCanvas(
                                      width: kShareImageWidth,
                                      height: kShareImageHeight,
                                      backgroundColor: kShareCanvasBackground,
                                      child: _ShareCard(
                                        recipient: widget.recipient,
                                        sender: widget.sender,
                                        dedication: _finalDedication,
                                        inspiration: _inspiration,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: PremiumDesign.s24),
                      _StaggeredItem(
                        index: 2,
                        controller: _entranceController,
                        child: Column(
                          children: [
                            _PremiumButton(
                              icon: Icons.mail_rounded,
                              label: 'Abrir caja de recuerdos 💌',
                              onPressed: _openMemoryBox,
                              outlined: true,
                            ),
                            const SizedBox(height: 12),
                            _PremiumButton(
                              icon: Icons.share_rounded,
                              label: 'Compartir detalle',
                              onPressed: _exportImage,
                            ),
                            const SizedBox(height: 32),
                            Opacity(
                                opacity: 0.4,
                                child: Text(
                                  'amarillas • tu jardín emocional',
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.5,
                                      color: iconColor),
                                )),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flower palettes per [FlowerTheme], so the style chosen in
/// [NameEntryFlower] actually shows up in the grown bouquet.
const Map<FlowerTheme, List<FlowerVariant>> _bouquetVariantsByTheme = {
  FlowerTheme.sunflower: [
    FlowerVariant(
        petalColor: Color(0xFFFFE082),
        centerColor: Color(0xFF8D4F12),
        petalCount: 7,
        heightFactor: 0.78,
        lean: -0.8),
    FlowerVariant(
        petalColor: Color(0xFFFFC107),
        centerColor: Color(0xFF6D3B0B),
        petalCount: 9,
        heightFactor: 1.0,
        lean: 0.1),
    FlowerVariant(
        petalColor: Color(0xFFFFF8E1),
        centerColor: Color(0xFFFFB300),
        petalCount: 6,
        heightFactor: 0.7,
        lean: 0.9),
  ],
  FlowerTheme.daisy: [
    FlowerVariant(
        petalColor: Color(0xFFFFFDF7),
        centerColor: Color(0xFFFFC107),
        petalCount: 13,
        heightFactor: 0.78,
        lean: -0.8),
    FlowerVariant(
        petalColor: Color(0xFFFFFDF7),
        centerColor: Color(0xFFFFB300),
        petalCount: 15,
        heightFactor: 1.0,
        lean: 0.1),
    FlowerVariant(
        petalColor: Color(0xFFFFFDF7),
        centerColor: Color(0xFFFFCA28),
        petalCount: 12,
        heightFactor: 0.7,
        lean: 0.9),
  ],
  FlowerTheme.rose: [
    FlowerVariant(
        petalColor: Color(0xFFEF9A9A),
        centerColor: Color(0xFFB71C1C),
        petalCount: 6,
        heightFactor: 0.78,
        lean: -0.8),
    FlowerVariant(
        petalColor: Color(0xFFE57373),
        centerColor: Color(0xFF8E0000),
        petalCount: 7,
        heightFactor: 1.0,
        lean: 0.1),
    FlowerVariant(
        petalColor: Color(0xFFFFCDD2),
        centerColor: Color(0xFFC62828),
        petalCount: 5,
        heightFactor: 0.7,
        lean: 0.9),
  ],
};

/// Ramo de tres flores que crecen desde el suelo, una tras otra.
class _GrowingBouquet extends StatelessWidget {
  const _GrowingBouquet(
      {required this.theme, required this.progress, required this.sway});
  final FlowerTheme theme;
  final double progress;
  final double sway;

  @override
  Widget build(BuildContext context) {
    final variants =
        _bouquetVariantsByTheme[theme] ?? _bouquetVariantsByTheme.values.first;
    return SizedBox(
      height: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < variants.length; i++)
            SizedBox(
              width: i == 1 ? 110 : 90,
              height: 260,
              child: GrowingFlower(
                variant: variants[i],
                // La flor central arranca primero; las laterales después
                progress:
                    ((progress - [0.12, 0.0, 0.2][i]) / 0.8).clamp(0.0, 1.0),
                sway: sway * (i.isEven ? 1 : -0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.recipient,
    required this.sender,
    required this.dedication,
    required this.inspiration,
  });
  final String recipient, sender, dedication;
  final DailyInspiration inspiration;

  static const _bg = Color(0xFF0B0820);
  static const _gold = Color(0xFFFFD54F);
  static const _white = Color(0xFFFFF8E1);

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
          const SizedBox(height: 32),
          Text(
            '$recipient,',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: _white,
              shadows: [Shadow(color: _gold.withAlpha(100), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              dedication,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: _white.withAlpha(220),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _gold.withAlpha(40)),
            ),
            child: Column(
              children: [
                Text(
                  '"${inspiration.quote}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: _white,
                  ),
                ),
                if (inspiration.author != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '— ${inspiration.author}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1.5, color: _gold.withAlpha(80)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'De: $sender',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _gold,
                  ),
                ),
              ),
              Container(width: 40, height: 1.5, color: _gold.withAlpha(80)),
            ],
          ),
          const SizedBox(height: 32),
          Opacity(
            opacity: 0.35,
            child: Text(
              'amarillas • tu jardín emocional 🌻',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: _white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem(
      {required this.index, required this.controller, required this.child});
  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.25).clamp(0.0, 1.0);
    final end = (start + 0.6).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: controller,
                curve: Interval(start, end, curve: Curves.easeOutQuart))),
        child: child,
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  const _PremiumButton(
      {required this.icon,
      required this.label,
      required this.onPressed,
      this.outlined = false});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color:
              outlined ? Colors.white.withAlpha(200) : PremiumDesign.softText,
          borderRadius: BorderRadius.circular(20),
          border: outlined
              ? Border.all(color: PremiumDesign.radiantGold.withAlpha(120))
              : null,
          boxShadow:
              outlined ? PremiumDesign.softShadow : PremiumDesign.deepShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: outlined ? PremiumDesign.softText : Colors.white,
                size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    color: outlined ? PremiumDesign.softText : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
