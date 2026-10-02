import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/background_layer.dart';
import 'package:yellow_flowers/features/flowers/models/default_messages.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/widgets/memory_box.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/particle_layer.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

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

  Future<void> _exportImage() async {
    try {
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
              '${directory.path}/gift_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(imagePath.path)],
          text: '✨ Un momento cultivado para ti: ${widget.recipient} 💛');
    } catch (e) {
      debugPrint('Export Error: $e');
    }
  }

  /// Si se abrió desde un enlace (sin historial), regresa al inicio.
  void _goBack() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()));
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
                        progress: _growController.value,
                        sway: math.sin(_petalController.value * 8 * math.pi),
                      ),
                      const SizedBox(height: PremiumDesign.s16),
                      _StaggeredItem(
                        index: 1,
                        controller: _entranceController,
                        child: _GiftCard(
                          dark: dark,
                          recipient: widget.recipient,
                          sender: widget.sender,
                          dedication: _finalDedication,
                        ),
                      ),
                      const SizedBox(height: PremiumDesign.s16),
                      _StaggeredItem(
                        index: 2,
                        controller: _entranceController,
                        child: _DailyQuoteCard(inspiration: _inspiration, dark: dark),
                      ),
                      const SizedBox(height: PremiumDesign.s24),
                      _StaggeredItem(
                        index: 3,
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
                                  'flores amarillas • tu jardín emocional',
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

/// Ramo de tres flores que crecen desde el suelo, una tras otra.
class _GrowingBouquet extends StatelessWidget {
  const _GrowingBouquet({required this.progress, required this.sway});
  final double progress;
  final double sway;

  static const _variants = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _variants.length; i++)
            SizedBox(
              width: i == 1 ? 110 : 90,
              height: 260,
              child: GrowingFlower(
                variant: _variants[i],
                // La flor central arranca primero; las laterales después
                progress: ((progress - [0.12, 0.0, 0.2][i]) / 0.8)
                    .clamp(0.0, 1.0),
                sway: sway * (i.isEven ? 1 : -0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyQuoteCard extends StatelessWidget {
  const _DailyQuoteCard({required this.inspiration, required this.dark});
  final DailyInspiration inspiration;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final main = dark ? const Color(0xFFFFF8E1) : PremiumDesign.softText;
    final soft = dark
        ? const Color(0xFFFFF8E1).withAlpha(200)
        : PremiumDesign.secondaryText;
    final gold = dark ? const Color(0xFFFFD54F) : PremiumDesign.radiantGold;
    return GlassCard(
      dark: dark,
      child: Column(
        children: [
          Text('FRASE DEL DÍA ☀️',
              style: PremiumDesign.sansLabel.copyWith(color: gold)),
          const SizedBox(height: 12),
          Text(
            inspiration.greeting,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: main,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '“${inspiration.quote}”',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: soft,
            ),
          ),
          if (inspiration.author != null) ...[
            const SizedBox(height: 8),
            Text(
              '— ${inspiration.author}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: gold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard(
      {required this.recipient,
      required this.sender,
      required this.dedication,
      required this.dark});
  final String recipient, sender, dedication;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final main = dark ? const Color(0xFFFFF8E1) : PremiumDesign.softText;
    final soft = dark
        ? const Color(0xFFFFF8E1).withAlpha(210)
        : PremiumDesign.secondaryText;
    final gold = dark ? const Color(0xFFFFD54F) : PremiumDesign.radiantGold;
    return GlassCard(
      dark: dark,
      glow: true,
      radius: 40,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('PARA ALGUIEN ESPECIAL 💛',
              style: PremiumDesign.sansLabel.copyWith(color: gold)),
          const SizedBox(height: 24),
          Text(
            '$recipient,',
            style: PremiumDesign.serifDisplay.copyWith(
              fontSize: 32,
              color: main,
              shadows: dark
                  ? [Shadow(color: gold.withAlpha(110), blurRadius: 20)]
                  : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              dedication,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: soft,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 1, color: gold.withAlpha(80)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'De: $sender',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: gold,
                  ),
                ),
              ),
              Container(width: 20, height: 1, color: gold.withAlpha(80)),
            ],
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
