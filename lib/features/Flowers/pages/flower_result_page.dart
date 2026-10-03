import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
  late final AnimationController _bgController;
  late final AnimationController _petalController;
  final GlobalKey _boundaryKey = GlobalKey();

  late final List<PetalSeed> _petalSeeds;
  late final String _finalDedication;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
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

    _initPetalSeeds();
    Future.delayed(
        const Duration(milliseconds: 500), () => _entranceController.forward());
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
    _bgController.dispose();
    _petalController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: PremiumDesign.softText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.close_rounded, color: PremiumDesign.softText),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _boundaryKey,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_bgController, _petalController, _entranceController]),
          builder: (context, _) => Stack(
            children: [
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
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      _StaggeredItem(
                        index: 0,
                        controller: _entranceController,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withAlpha(100),
                                  blurRadius: 80,
                                  spreadRadius: 20)
                            ],
                          ),
                          child: Lottie.asset(
                            'assets/lottie/flower_bloom.json',
                            height: 280,
                            repeat: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: PremiumDesign.s16),
                      _StaggeredItem(
                        index: 1,
                        controller: _entranceController,
                        child: _GiftCard(
                          recipient: widget.recipient,
                          sender: widget.sender,
                          dedication: _finalDedication,
                        ),
                      ),
                      const Spacer(flex: 2),
                      _StaggeredItem(
                        index: 2,
                        controller: _entranceController,
                        child: Column(
                          children: [
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
                                      color: PremiumDesign.softText),
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

class _GiftCard extends StatelessWidget {
  const _GiftCard(
      {required this.recipient,
      required this.sender,
      required this.dedication});
  final String recipient, sender, dedication;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: PremiumDesign.deepShadow,
        border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
        gradient: LinearGradient(
          colors: [Colors.white.withAlpha(230), Colors.white.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Stack(
            children: [
              // Decorative seal
              const Positioned(
                top: -10,
                right: -10,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.auto_awesome,
                      size: 80, color: PremiumDesign.radiantGold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PARA ALGUIEN ESPECIAL 💛',
                        style: PremiumDesign.sansLabel),
                    const SizedBox(height: 24),
                    Text(
                      '$recipient,',
                      style: PremiumDesign.serifDisplay.copyWith(fontSize: 32),
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
                          color: PremiumDesign.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 20,
                            height: 1,
                            color: PremiumDesign.radiantGold.withAlpha(80)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'De: $sender',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesign.radiantGold,
                            ),
                          ),
                        ),
                        Container(
                            width: 20,
                            height: 1,
                            color: PremiumDesign.radiantGold.withAlpha(80)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      {required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: PremiumDesign.softText,
          borderRadius: BorderRadius.circular(20),
          boxShadow: PremiumDesign.deepShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
