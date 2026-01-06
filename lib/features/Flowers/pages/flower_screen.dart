import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_themed.dart';
import 'package:yellow_flowers/features/flowers/widgets/story_card.dart';
import 'package:yellow_flowers/utils/app_theme.dart';
import 'package:yellow_flowers/utils/constants.dart';

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
              Align(
                alignment: const Alignment(0, -0.15),
                child: Opacity(
                  opacity: _messageAnimationController.value,
                  child: RepaintBoundary(
                    key: _shareKey,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.88),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, anim) {
                              final curved = CurvedAnimation(
                                  parent: anim, curve: Curves.easeOut);
                              return FadeTransition(
                                opacity: curved,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.98, end: 1.0)
                                        .animate(curved),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '${widget.recipientName}, $_currentMessage',
                              key: ValueKey(_currentMessage),
                              textAlign: TextAlign.center,
                              style: (widget.fancyName
                                      ? GoogleFonts.raleway()
                                          .copyWith(fontStyle: FontStyle.italic)
                                      : GoogleFonts.poppins())
                                  .copyWith(
                                color: Colors.black87,
                                fontSize: 26, // Increased from 22
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _shareBloomController,
                                      builder: (context, _) => CustomPaint(
                                        painter: _BloomPainter(
                                          progress: _shareBloomController.value,
                                          color: Colors.pinkAccent,
                                        ),
                                        size: const Size(48, 48),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Compartir',
                                      onPressed: () async {
                                        _shareBloomController.forward(from: 0);
                                        await _shareMessageCard();
                                      },
                                      icon: const Icon(
                                        Icons.share_rounded,
                                        color: Colors.pinkAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Plantar en mi Jardín',
                                onPressed: _saveStoryCard,
                                icon: const Icon(
                                  Icons.yard_rounded,
                                  color: AppTheme.leafGreen,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Music Player Control
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: _MusicPlayerButton(player: _audioPlayer),
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
                  animation: _flowerControllers[index],
                  builder: (context, child) {
                    final rnd = math.Random(index);
                    final baseX = rnd.nextDouble() * screenWidth;
                    final y = screenHeight * 0.38 +
                        rnd.nextDouble() * (screenHeight * 0.45);
                    final t = _flowerControllers[index].value;
                    // Animation styles
                    double scale = 1.0;
                    double angle = 0.0;
                    double swayX = 0.0;
                    switch (widget.animationStyle) {
                      case FlowerAnimationStyle.pulse:
                        scale = 0.95 + math.sin(t * 2 * math.pi) * 0.06;
                        break;
                      case FlowerAnimationStyle.spin:
                        angle = math.sin(t * 2 * math.pi) * 0.35; // ~20°
                        scale = 0.98 + math.sin(t * 2 * math.pi) * 0.02;
                        break;
                      case FlowerAnimationStyle.sway:
                        swayX = math.sin(t * 2 * math.pi + index) * 14.0;
                        scale = 0.98 + math.sin(t * 2 * math.pi) * 0.02;
                        break;
                    }
                    return Positioned(
                      left: baseX + swayX,
                      top: y,
                      child: GestureDetector(
                        onTap: () {
                          _sparkleBurstController.forward(from: 0);
                          // Future: Play sound here
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

class _BloomPainter extends CustomPainter {
  _BloomPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));

    // Petals
    const petals = 8;
    const baseLen = 10.0;
    final len = baseLen + 22.0 * t;
    final width = 6.0 + 8.0 * t;
    final yOffset = 6.0 + 8.0 * t;
    final petalPaint = Paint()
      ..color = color.withValues(alpha: 0.5 * (1.0 - t))
      ..style = PaintingStyle.fill;
    for (var i = 0; i < petals; i++) {
      canvas.save();
      canvas.rotate(i * (2 * math.pi / petals));
      final rect = Rect.fromCenter(
        center: Offset(0, -yOffset - len / 2),
        width: width,
        height: len,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(width / 2)),
        petalPaint,
      );
      canvas.restore();
    }

    final corePaint = Paint()..color = color.withValues(alpha: 0.6 * (1.0 - t));
    canvas.drawCircle(Offset.zero, 6.0 + 6.0 * t, corePaint);
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _MusicPlayerButton extends StatefulWidget {
  final AudioPlayer player;
  const _MusicPlayerButton({required this.player});

  @override
  State<_MusicPlayerButton> createState() => _MusicPlayerButtonState();
}

class _MusicPlayerButtonState extends State<_MusicPlayerButton> {
  bool _isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            // Check if player has source, if not, prompt to pick
            if (widget.player.duration == null && _isPlaying) {
              _showAudioOptions(context);
              return;
            }
            if (_isPlaying) {
              widget.player.pause();
            } else {
              widget.player.play();
            }
          },
          onLongPress: () => _showAudioOptions(context),
          child: StreamBuilder<PlayerState>(
            stream: widget.player.playerStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;
              _isPlaying = playing; // Sync local state

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  playing ? Icons.music_note_rounded : Icons.music_off_rounded,
                  color: AppTheme.textDark,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAudioOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ambientación Musical 🎵",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.audio_file_rounded,
                  color: AppTheme.sunnyGold),
              title: const Text("Elegir archivo de mi celular"),
              onTap: () {
                Navigator.pop(ctx);
                _pickAudioFile();
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.open_in_new_rounded, color: Colors.green),
              title: const Text("Abrir Spotify"),
              onTap: () {
                Navigator.pop(ctx);
                _openExternalApp("spotify://", "https://open.spotify.com");
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_filled_rounded,
                  color: Colors.red),
              title: const Text("Abrir YouTube Music"),
              onTap: () {
                Navigator.pop(ctx);
                _openExternalApp(
                    "youtubemusic://", "https://music.youtube.com");
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        await widget.player.setFilePath(result.files.single.path!);
        widget.player.play();
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _openExternalApp(String schema, String webUrl) async {
    final Uri schemaUri = Uri.parse(schema);
    final Uri webUri = Uri.parse(webUrl);

    try {
      // 1. Intentar abrir la APP nativa (verificamos si se puede abrir)
      bool launchedApp = false;
      try {
        if (await canLaunchUrl(schemaUri)) {
          launchedApp =
              await launchUrl(schemaUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint("Error checking/launching app schema: $e");
      }

      if (!launchedApp) {
        // 2. Si falla la app nativa, abrir la WEB en el navegador
        // Nota: No usamos canLaunchUrl aquí para evitar falsos negativos en algunos dispositivos.
        // Intentamos lanzar directamente.
        debugPrint("Intentando fallback web: $webUrl");
        if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $webUrl';
        }
      }
    } catch (e) {
      debugPrint("Error launching fallback web: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace 😓'),
          ),
        );
      }
    }
  }
}
