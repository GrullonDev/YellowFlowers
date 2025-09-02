import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import 'package:yellow_flowers/features/Flowers/widgets/flower.dart';

class FlowerScreen extends StatefulWidget {
  final String recipientName;
  const FlowerScreen({super.key, required this.recipientName});

  @override
  State<FlowerScreen> createState() => _FlowerScreenState();
}

class _FlowerScreenState extends State<FlowerScreen>
    with TickerProviderStateMixin {
  // Animations
  late final List<AnimationController> _flowerControllers;
  late final AnimationController _messageAnimationController;
  late final List<AnimationController> _sparkleControllers;
  late final AnimationController _bgController;
  late final AnimationController _petalController;

  // Background gradient
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  // Timers
  late final Timer _timer;

  // Counts
  final int _sparkleCount = 30;
  final int _flowerCount = 24; // minimalista, menos saturación visual
  final int _petalCount = 20;

  // Petal seeds
  late final List<_PetalSeed> _petalSeeds;

  // Share as image
  final GlobalKey _shareKey = GlobalKey();

  // Messages
  static const List<String> _messages = [
    "Gracias por ser parte de mi vida, contigo todo es mejor. ❤️❤️",
    "Eres la flor más hermosa de mi jardín. 🌼",
    "Tu sonrisa ilumina mis días. ☀️ ☀️ ☀️",
    "Contigo, cada momento es especial. ✨",
    "Eres mi compañera, amiga y amor. 💖",
    "Tu fuerza interior brilla más que mil estrellas. ⭐️",
    "Eres capaz de lograr todo lo que te propongas. 💪",
    "Tu valentía inspira a quienes te rodean. 🦋",
    "Cada día brillas con luz propia. 🌟",
    "Tu determinación mueve montañas. 🏔️",
    "Eres un ejemplo de fortaleza y gracia. 👑",
    "Tu bondad hace del mundo un lugar mejor. 🌈",
    "No hay límites para una mujer que sueña en grande. 🚀",
    "Tu inteligencia y belleza son incomparables. 💫",
    "Eres la protagonista de tu propia historia. 📖",
    "Tu presencia alegra cada espacio. 🌺",
    "Mereces todo lo hermoso que la vida tiene. 🎀",
    "Tu esencia es única y maravillosa. 💝",
    "Eres un regalo para quienes te conocen. 🎁",
    "Tu corazón es un tesoro invaluable. 💎",
  ];
  late String _currentMessage;

  @override
  void initState() {
    super.initState();

    // Flowers
    _flowerControllers = List.generate(
      _flowerCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true),
    );

    // Sparkles
    _sparkleControllers = List.generate(
      _sparkleCount,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1200 + math.Random().nextInt(1400)),
      )..repeat(reverse: true),
    );

    // Message card fade-in
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Background gradient animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _topColorAnim = ColorTween(
      begin: const Color(0xFFFFF7C2), // amarillo suave
      end: const Color(0xFFFFE0E0), // rosa pálido
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: const Color(0xFFFFD3B6), // durazno
      end: const Color(0xFFFFB3C6), // rosa más intenso
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    // Falling petals
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    final rnd = math.Random();
    _petalSeeds = List.generate(_petalCount, (i) {
      return _PetalSeed(
        startX: rnd.nextDouble(),
        startY: rnd.nextDouble(),
        swayAmp: 18 + rnd.nextDouble() * 22,
        swayFreq: 0.6 + rnd.nextDouble() * 1.1,
        size: 10 + rnd.nextDouble() * 12,
        rotationSpeed: 0.2 + rnd.nextDouble() * 0.6,
        phase: rnd.nextDouble(),
      );
    });

    _currentMessage = _messages[rnd.nextInt(_messages.length)];

    // Refresh message periodically
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _currentMessage = _messages[rnd.nextInt(_messages.length)];
      });
    });
  }

  @override
  void dispose() {
    for (final c in _flowerControllers) c.dispose();
    for (final c in _sparkleControllers) c.dispose();
    _messageAnimationController.dispose();
    _bgController.dispose();
    _petalController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _shareMessageCard() async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(
        pngBytes,
        mimeType: 'image/png',
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          fileNameOverrides: ['mensaje_flores.png'],
          text: 'Un mensaje para ti 💛',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo compartir la tarjeta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _petalController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Dynamic gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _topColorAnim.value ?? const Color(0xFFFFF7C2),
                      _bottomColorAnim.value ?? const Color(0xFFFFB3C6),
                    ],
                  ),
                ),
              ),

              // Floating message card in the center top
              Align(
                alignment: const Alignment(0, -0.15),
                child: Opacity(
                  opacity: _messageAnimationController.value,
                  child: RepaintBoundary(
                    key: _shareKey,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.88),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('✨🌻💛', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            "${widget.recipientName}, $_currentMessage",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Compartir',
                                onPressed: _shareMessageCard,
                                icon: const Icon(Icons.share_rounded, color: Colors.pinkAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Soft sparkles around the message
              ...List.generate(
                _sparkleCount,
                (index) => AnimatedBuilder(
                  animation: _sparkleControllers[index],
                  builder: (context, child) {
                    final x = math.Random(index * 997).nextDouble() * screenWidth;
                    final y = screenHeight * 0.15 + math.Random(index * 1337).nextDouble() * (screenHeight * 0.35);
                    final sizeDot = 2.0 + _sparkleControllers[index].value * 3.0;
                    final opacity = 0.2 + _sparkleControllers[index].value * 0.6;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: sizeDot,
                          height: sizeDot,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Elegant minimal flowers
              ...List.generate(
                _flowerCount,
                (index) => AnimatedBuilder(
                  animation: _flowerControllers[index],
                  builder: (context, child) {
                    final rnd = math.Random(index);
                    final x = rnd.nextDouble() * screenWidth;
                    final y = screenHeight * 0.38 + rnd.nextDouble() * (screenHeight * 0.45);
                    final scale = 0.9 + math.sin(_flowerControllers[index].value * 2 * math.pi) * 0.05;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: screenWidth / 11,
                          height: screenHeight / 2.3,
                          child: const Flor(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Falling petals
              ...List.generate(_petalCount, (i) {
                final seed = _petalSeeds[i];
                final t = (_petalController.value + seed.phase) % 1.0;
                final y = (t * (screenHeight + 60)) - 60 + seed.startY * 40;
                final x = seed.startX * screenWidth + math.sin(t * seed.swayFreq * 2 * math.pi) * seed.swayAmp;
                final rot = t * seed.rotationSpeed * 2 * math.pi;
                return Positioned(
                  left: x,
                  top: y % (screenHeight + 20) - 20,
                  child: Transform.rotate(
                    angle: rot,
                    child: _Petal(size: seed.size),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _Petal extends StatelessWidget {
  const _Petal({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.8,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE07D).withOpacity(0.9),
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE07D).withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _PetalSeed {
  _PetalSeed({
    required this.startX,
    required this.startY,
    required this.swayAmp,
    required this.swayFreq,
    required this.size,
    required this.rotationSpeed,
    required this.phase,
  });
  final double startX;
  final double startY;
  final double swayAmp;
  final double swayFreq;
  final double size;
  final double rotationSpeed;
  final double phase;
}
