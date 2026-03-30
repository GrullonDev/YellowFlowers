import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:just_audio/just_audio.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_themed.dart';
import 'package:yellow_flowers/features/flowers/widgets/story_card.dart';
import 'package:yellow_flowers/utils/app_theme.dart';
import 'package:yellow_flowers/utils/constants.dart';
import 'package:yellow_flowers/widgets/typewriter_text.dart';
import 'package:yellow_flowers/features/music/widgets/premium_music_player.dart';

class FlowerScreen extends StatefulWidget {
  const FlowerScreen({
    super.key,
    required this.recipientName,
    this.theme = FlowerTheme.daisy,
    this.mood = Mood.joy,
    this.fancyName = false,
    this.animationStyle = FlowerAnimationStyle.sway,
  });
  final String recipientName;
  final FlowerTheme theme;
  final Mood mood;
  final bool fancyName;
  final FlowerAnimationStyle animationStyle;

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
  late final AnimationController _sparkleBurstController;
  late final AnimationController _shareBloomController;
  late final AnimationController _heroEntranceController;

  // Background gradient
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  // Timers
  late final Timer _timer;

  // Counts
  final int _sparkleCount = 30;
  final int _flowerCount = 24;
  final int _petalCount = 20;

  // Petal seeds
  late final List<_PetalSeed> _petalSeeds;

  // Share as image
  final GlobalKey _shareKey = GlobalKey();
  // Persistent export boundary to avoid overlay race conditions
  final GlobalKey _exportBoundaryKey = GlobalKey();
  bool _exportActive = false;
  // Offstage story builder key (uses StoryCard.repaintKey internally)

  // Messages
  static const List<String> _messages = [
    'Gracias por ser parte de mi vida, contigo todo es mejor. ❤️❤️',
    'Eres la flor más hermosa de mi jardín. 🌼',
    'Tu sonrisa ilumina mis días. ☀️ ☀️ ☀️',
    'Contigo, cada momento es especial. ✨',
    'Eres mi compañera, amiga y amor. 💖',
    'Tu fuerza interior brilla más que mil estrellas. ⭐️',
    'Eres capaz de lograr todo lo que te propongas. 💪',
    'Tu valentía inspira a quienes te rodean. 🦋',
    'Cada día brillas con luz propia. 🌟',
    'Tu determinación mueve montañas. 🏔️',
    'Eres un ejemplo de fortaleza y gracia. 👑',
    'Tu bondad hace del mundo un lugar mejor. 🌈',
    'No hay límites para una mujer que sueña en grande. 🚀',
    'Tu inteligencia y belleza son incomparables. 💫',
    'Eres la protagonista de tu propia historia. 📖',
    'Tu presencia alegra cada espacio. 🌺',
    'Mereces todo lo hermoso que la vida tiene. 🎀',
    'Tu esencia es única y maravillosa. 💝',
    'Eres un regalo para quienes te conocen. 🎁',
    'Tu corazón es un tesoro invaluable. 💎',
  ];
  late String _currentMessage;

  // Audio
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _initAudio();

    _flowerControllers = List.generate(
      _flowerCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true),
    );

    _sparkleControllers = List.generate(
      _sparkleCount,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1200 + math.Random().nextInt(1400)),
      )..repeat(reverse: true),
    );

    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    final gradients = _gradientsForMood(widget.mood);
    _topColorAnim = ColorTween(
      begin: gradients.$1,
      end: gradients.$2,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: gradients.$3,
      end: gradients.$4,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _sparkleBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shareBloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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

    _heroEntranceController = AnimationController(
      vsync: this,
      duration: PremiumDesign.slow,
    )..forward();

    _currentMessage = _messages[rnd.nextInt(_messages.length)];

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _currentMessage = _messages[rnd.nextInt(_messages.length)];
      });
      // Dispara un destello extra de brillos cada cambio de mensaje
      _sparkleBurstController.forward(from: 0);
    });
  }

  Future<void> _initAudio() async {
    try {
      // Configuración de audio
      await _audioPlayer.setLoopMode(LoopMode.one);
      // Intentar cargar asset de música si existe, sino silenciar
      /* 
      // Comentado para evitar error 'UnrecognizedInputFormatException' dado que el archivo no existe aún.
      // El usuario puede seleccionar su propia música.
      try {
        await _audioPlayer.setAsset('assets/music/gentle_piano.mp3');
        _audioPlayer.setVolume(0.3);
        _audioPlayer.play();
      } catch (e) {
        debugPrint("Música no encontrada (esperado si no hay asset): $e");
      }
      */
    } catch (e) {
      debugPrint("Error inicializando audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    for (final c in _flowerControllers) {
      c.dispose();
    }
    for (final c in _sparkleControllers) {
      c.dispose();
    }
    _messageAnimationController.dispose();
    _bgController.dispose();
    _petalController.dispose();
    _sparkleBurstController.dispose();
    _shareBloomController.dispose();
    _heroEntranceController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _shareMessageCard() async {
    try {
      // Activa render temporal del StoryCard oculto
      if (mounted) setState(() => _exportActive = true);
      // Espera 2 frames para garantizar layout y pintado del RepaintBoundary persistente
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      // Frame extra por seguridad en dispositivos lentos
      await WidgetsBinding.instance.endOfFrame;
      Uint8List? pngBytes;
      try {
        pngBytes =
            await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 2.0);
      } catch (_) {}
      pngBytes ??=
          await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 1.5);
      pngBytes ??=
          await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 1.0);
      if (pngBytes == null) return;
      // Save to temp file then share
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/mensaje_flores.png';
      final f = File(path);
      await f.writeAsBytes(pngBytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(f.path, mimeType: 'image/png', name: 'mensaje_flores.png')
          ],
          text: 'Un mensaje para ti 💛',
        ),
      );
      if (mounted) setState(() => _exportActive = false);
    } catch (e) {
      if (mounted) setState(() => _exportActive = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo compartir la tarjeta: $e')),
      );
    }
  }

  Future<void> _saveStoryCard() async {
    try {
      // Activa render temporal del StoryCard oculto
      if (mounted) setState(() => _exportActive = true);
      // Espera 2 frames para garantizar layout y pintado del RepaintBoundary persistente
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      // Frame extra por seguridad en dispositivos lentos
      await WidgetsBinding.instance.endOfFrame;
      Uint8List? pngBytes;
      try {
        pngBytes =
            await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 2.0);
      } catch (_) {}
      pngBytes ??=
          await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 1.5);
      pngBytes ??=
          await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 1.0);
      if (pngBytes == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/YellowFlowers');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${folder.path}/story_$ts.png');
      await file.writeAsBytes(pngBytes, flush: true);

      // Save to Gallery
      try {
        await Gal.putImage(file.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Tarjeta guardada en tu Galería de fotos! 📸'),
              backgroundColor: AppTheme.leafGreen,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saving to gallery: $e');
        // Fallback or just show file path if gallery fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Guardado en archivos: ${file.path}')),
          );
        }
      }

      if (mounted) setState(() => _exportActive = false);
    } catch (e) {
      if (mounted) setState(() => _exportActive = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la tarjeta: $e')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _petalController,
          _sparkleBurstController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              // Hidden story card rendered only during export
              if (_exportActive)
                IgnorePointer(
                  ignoring: true,
                  child: Opacity(
                    opacity: 0.01, // pequeño pero visible al motor para pintar
                    child: Center(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 1080,
                          height: 1920,
                          child: StoryCard(
                            name: widget.recipientName,
                            message: _currentMessage,
                            qrUrl: kQrCodeUrl,
                            topColor:
                                _topColorAnim.value ?? const Color(0xFFFFF7C2),
                            bottomColor: _bottomColorAnim.value ??
                                const Color(0xFFFFB3C6),
                            fancyName: widget.fancyName,
                            boundaryKey: _exportBoundaryKey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
              // Soft Particles Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _SoftParticlesPainter(
                    animation: _bgController,
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.65),
                child: AnimatedBuilder(
                  animation: _messageAnimationController,
                  builder: (context, _) => Opacity(
                    opacity: _messageAnimationController.value,
                    child: RepaintBoundary(
                      key: _shareKey,
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: screenWidth * 0.88),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: PremiumDesign.premiumRadius,
                          boxShadow: PremiumDesign.softShadow,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: PremiumDesign.premiumRadius,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('✨🌻💛',
                                    style: PremiumDesign.sansBody
                                        .copyWith(fontSize: 20)),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: PremiumDesign.medium,
                                  child: TypewriterText(
                                    key: ValueKey(_currentMessage),
                                    text:
                                        '${widget.recipientName}, $_currentMessage',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.playfairDisplay(
                                      color: PremiumDesign.softText,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _PremiumInteractionButton(
                                      icon: Icons.share_rounded,
                                      color: Colors.pinkAccent,
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        _shareBloomController.forward(from: 0);
                                        await _shareMessageCard();
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    _PremiumInteractionButton(
                                      icon: Icons.yard_rounded,
                                      color: PremiumDesign.leafGreen,
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _saveStoryCard();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Premium Music Player
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: PremiumMusicPlayer(player: _audioPlayer),
              ),
              ...List.generate(
                _sparkleCount,
                (index) => AnimatedBuilder(
                  animation: _sparkleControllers[index],
                  builder: (context, child) {
                    final x =
                        math.Random(index * 997).nextDouble() * screenWidth;
                    final y = screenHeight * 0.15 +
                        math.Random(index * 1337).nextDouble() *
                            (screenHeight * 0.35);
                    final baseSize =
                        2.0 + _sparkleControllers[index].value * 3.0;
                    final baseOpacity =
                        0.2 + _sparkleControllers[index].value * 0.6;
                    final burst = 1.0 + 0.8 * _sparkleBurstController.value;
                    final sizeDot = baseSize * burst;
                    final opacity = (baseOpacity *
                            (1.0 + 1.0 * _sparkleBurstController.value))
                        .clamp(0.0, 1.0);
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
              ...List.generate(
                _flowerCount,
                (index) => AnimatedBuilder(
                  animation: Listenable.merge(
                      [_flowerControllers[index], _heroEntranceController]),
                  builder: (context, child) {
                    final rnd = math.Random(index);
                    final baseX = rnd.nextDouble() * screenWidth;
                    final targetY = screenHeight * 0.38 +
                        rnd.nextDouble() * (screenHeight * 0.45);

                    // Hero Entrance
                    final tEntrance = _heroEntranceController.value;
                    final entranceY = (1.0 - tEntrance) * 100;
                    final entranceBlur = (1.0 - tEntrance) * 10;
                    final entranceOpacity =
                        Interval(0.2, 1.0, curve: Curves.easeOut)
                            .transform(tEntrance);
                    final entranceScale = 0.8 + 0.2 * tEntrance;

                    final t = _flowerControllers[index].value;
                    // Animation styles
                    double scale = entranceScale;
                    double angle = 0.0;
                    double swayX = 0.0;
                    switch (widget.animationStyle) {
                      case FlowerAnimationStyle.pulse:
                        scale *= 0.95 + math.sin(t * 2 * math.pi) * 0.06;
                        break;
                      case FlowerAnimationStyle.spin:
                        angle = math.sin(t * 2 * math.pi) * 0.35; // ~20°
                        scale *= 0.98 + math.sin(t * 2 * math.pi) * 0.02;
                        break;
                      case FlowerAnimationStyle.sway:
                        swayX = math.sin(t * 2 * math.pi + index) * 14.0;
                        scale *= 0.98 + math.sin(t * 2 * math.pi) * 0.02;
                        break;
                    }

                    // Soft Parallax
                    final parallaxX = (math.sin(t * 0.5 * math.pi) * 5.0).abs();

                    return Positioned(
                      left: baseX + swayX + parallaxX,
                      top: targetY + entranceY,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            sigmaX: entranceBlur, sigmaY: entranceBlur),
                        child: Opacity(
                          opacity: entranceOpacity,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _sparkleBurstController.forward(from: 0);
                            },
                            child: Transform.rotate(
                              angle: angle,
                              child: Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: screenWidth / 11,
                                  height: screenHeight / 2.3,
                                  child: widget.theme == FlowerTheme.daisy
                                      ? const Flor()
                                      : FlowerThemed(theme: widget.theme),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ...List.generate(_petalCount, (i) {
                final seed = _petalSeeds[i];
                final t = (_petalController.value + seed.phase) % 1.0;
                final y = (t * (screenHeight + 60)) - 60 + seed.startY * 40;
                final x = seed.startX * screenWidth +
                    math.sin(t * seed.swayFreq * 2 * math.pi) * seed.swayAmp;
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

// Gradientes por estado de ánimo
(Color, Color, Color, Color) _gradientsForMood(Mood mood) {
  switch (mood) {
    case Mood.joy:
      return (
        const Color(0xFFFFF7C2),
        const Color(0xFFFFE8A3),
        const Color(0xFFFFD3B6),
        const Color(0xFFFFB347),
      );
    case Mood.calm:
      return (
        const Color(0xFFEDE7F6),
        const Color(0xFFD1C4E9),
        const Color(0xFFB39DDB),
        const Color(0xFF9575CD),
      );
    case Mood.passion:
      return (
        const Color(0xFFFFE0E0),
        const Color(0xFFFFC0CB),
        const Color(0xFFFFA6C1),
        const Color(0xFFFF77A9),
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
        color: const Color(0xFFFFE07D).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE07D).withValues(alpha: 0.4),
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

class _SoftParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Particle> particles;

  _SoftParticlesPainter({required this.animation})
      : particles = List.generate(15, (i) {
          final rnd = math.Random(i);
          return _Particle(
            x: rnd.nextDouble(),
            y: rnd.nextDouble(),
            speed: 0.05 + rnd.nextDouble() * 0.1,
            size: 40 + rnd.nextDouble() * 80,
            opacity: 0.05 + rnd.nextDouble() * 0.1,
          );
        }),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    
    for (final p in particles) {
      final yOffset = (animation.value * p.speed * size.height) % size.height;
      final xOffset = math.sin(animation.value * 2 * math.pi * p.speed) * 20;
      
      paint.color = Colors.white.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width + xOffset, (p.y * size.height + yOffset) % size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoftParticlesPainter oldDelegate) => true;
}

class _Particle {
  final double x, y, speed, size, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}



class _PremiumInteractionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _PremiumInteractionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_PremiumInteractionButton> createState() =>
      __PremiumInteractionButtonState();
}

class __PremiumInteractionButtonState extends State<_PremiumInteractionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PremiumDesign.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 28),
        ),
      ),
    );
  }
}
