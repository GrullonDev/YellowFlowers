import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:just_audio/just_audio.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/story_card.dart';
import 'package:yellow_flowers/utils/constants.dart';
import 'package:yellow_flowers/features/music/widgets/premium_music_player.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/background_layer.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/flower_field_view.dart';
import 'package:yellow_flowers/features/flowers/widgets/screen_parts/message_view.dart';

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
  // Controllers
  late final List<AnimationController> _flowerControllers;
  late final List<AnimationController> _sparkleControllers;
  late final AnimationController _bgController;
  late final AnimationController _petalController;
  late final AnimationController _sparkleBurstController;
  late final AnimationController _heroEntranceController;

  // Background Anims
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  // Timers & Data
  late final Timer _timer;
  final int _sparkleCount = 30;
  final int _flowerCount = 24;
  final int _petalCount = 20;
  late final List<PetalSeed> _petalSeeds;
  final GlobalKey _exportBoundaryKey = GlobalKey();
  bool _exportActive = false;

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
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initPetals();
    _initAudio();
    _currentMessage = _messages[math.Random().nextInt(_messages.length)];
    _timer =
        Timer.periodic(const Duration(seconds: 7), (_) => _rotateMessage());
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _heroEntranceController.forward();
    });
  }

  void _initControllers() {
    _flowerControllers = List.generate(
      _flowerCount,
      (i) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true),
    );
    _sparkleControllers = List.generate(
      _sparkleCount,
      (i) => AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 1200 + math.Random().nextInt(1400)))
        ..repeat(reverse: true),
    );
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat(reverse: true);
    _petalController =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..repeat();
    _sparkleBurstController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _heroEntranceController =
        AnimationController(vsync: this, duration: PremiumDesign.slow);

    final gradients = _gradientsForMood(widget.mood);
    _topColorAnim = ColorTween(begin: gradients.$1, end: gradients.$2).animate(
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(begin: gradients.$3, end: gradients.$4)
        .animate(
            CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  void _initPetals() {
    final rnd = math.Random();
    _petalSeeds = List.generate(_petalCount, (i) {
      return PetalSeed(
        startX: rnd.nextDouble(),
        startY: rnd.nextDouble(),
        swayAmp: 18 + rnd.nextDouble() * 22,
        swayFreq: 0.6 + rnd.nextDouble() * 1.1,
        size: 10 + rnd.nextDouble() * 12,
        rotationSpeed: 0.2 + rnd.nextDouble() * 0.6,
        phase: rnd.nextDouble(),
      );
    });
  }

  void _rotateMessage() {
    if (!mounted) return;
    setState(() {
      _currentMessage = _messages[math.Random().nextInt(_messages.length)];
    });
    _sparkleBurstController.forward(from: 0);
  }

  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer.cancel();
    for (final c in _flowerControllers) {
      c.dispose();
    }
    for (final c in _sparkleControllers) {
      c.dispose();
    }
    _bgController.dispose();
    _petalController.dispose();
    _sparkleBurstController.dispose();
    _heroEntranceController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _showConfirmation(String msg, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => _ConfirmationDialog(message: msg, icon: icon),
    );
  }

  Future<void> _shareCard() async {
    setState(() => _exportActive = true);
    await Future.delayed(const Duration(milliseconds: 100));
    final bytes =
        await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 2.0);
    if (bytes != null) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/mensaje_flores_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)], text: 'Un regalo para ti 💛');
    }
    setState(() => _exportActive = false);
  }

  Future<void> _saveCard() async {
    setState(() => _exportActive = true);
    await Future.delayed(const Duration(milliseconds: 100));
    final bytes =
        await StoryCard.exportPng(_exportBoundaryKey, pixelRatio: 2.0);
    if (bytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final f = await File(
              '${dir.path}/flor_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await f.writeAsBytes(bytes);
      try {
        await Gal.putImage(f.path);
        _showConfirmation(
            '¡Flor guardada en tu galería!', Icons.check_circle_rounded);
      } catch (_) {
        _showConfirmation(
            'Guardado en archivos del dispositivo.', Icons.folder_rounded);
      }
    }
    setState(() => _exportActive = false);
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PremiumMusicPlayer(player: _audioPlayer),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_bgController, _petalController, _sparkleBurstController]),
        builder: (context, _) => Stack(
          children: [
            // Export Hidden Layer
            if (_exportActive)
              _HiddenExportCard(
                boundaryKey: _exportBoundaryKey,
                name: widget.recipientName,
                message: _currentMessage,
                topColor: _topColorAnim.value ?? Colors.white,
                bottomColor: _bottomColorAnim.value ?? Colors.white,
                fancyName: widget.fancyName,
              ),

            // Layers Modularizados
            BackgroundLayer(
              topColor: _topColorAnim.value ?? Colors.white,
              bottomColor: _bottomColorAnim.value ?? Colors.white,
              bgAnimation: _bgController,
              petalAnimation: _petalController,
              petalSeeds: _petalSeeds,
            ),

            FlowerFieldView(
              flowerControllers: _flowerControllers,
              sparkleControllers: _sparkleControllers,
              entranceController: _heroEntranceController,
              sparkleBurstController: _sparkleBurstController,
              animationStyle: widget.animationStyle,
              theme: widget.theme,
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: PremiumDesign.s24, vertical: PremiumDesign.s16),
                child: Column(
                  children: [
                    MessageView(
                      recipientName: widget.recipientName,
                      message: _currentMessage,
                      mood: widget.mood,
                      entranceController: _heroEntranceController,
                      onShare: _shareCard,
                      onSave: _saveCard,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS PRIVADOS DE SOPORTE
// ═══════════════════════════════════════════════════════════════════════════════

class _HiddenExportCard extends StatelessWidget {
  const _HiddenExportCard({
    required this.boundaryKey,
    required this.name,
    required this.message,
    required this.topColor,
    required this.bottomColor,
    required this.fancyName,
  });
  final GlobalKey boundaryKey;
  final String name;
  final String message;
  final Color topColor;
  final Color bottomColor;
  final bool fancyName;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.01,
        child: Center(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: 1080,
              height: 1920,
              child: StoryCard(
                name: name,
                message: message,
                qrUrl: kQrCodeUrl,
                topColor: topColor,
                bottomColor: bottomColor,
                fancyName: fancyName,
                boundaryKey: boundaryKey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(PremiumDesign.s32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: PremiumDesign.premiumRadius,
            boxShadow: PremiumDesign.premiumShadow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PremiumDesign.leafGreen, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: PremiumDesign.softText)),
            const SizedBox(height: 24),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Entendido 💛',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        color: PremiumDesign.softText))),
          ],
        ),
      ),
    );
  }
}

(Color, Color, Color, Color) _gradientsForMood(Mood mood) {
  switch (mood) {
    case Mood.joy:
      return (
        const Color(0xFFFFF7C2),
        const Color(0xFFFFE8A3),
        const Color(0xFFFFD3B6),
        const Color(0xFFFFB347)
      );
    case Mood.calm:
      return (
        const Color(0xFFEDE7F6),
        const Color(0xFFD1C4E9),
        const Color(0xFFB39DDB),
        const Color(0xFF9575CD)
      );
    case Mood.passion:
      return (
        const Color(0xFFFFE0E0),
        const Color(0xFFFFC0CB),
        const Color(0xFFFFA6C1),
        const Color(0xFFFF77A9)
      );
  }
}
