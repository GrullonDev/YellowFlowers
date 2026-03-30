import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:yellow_flowers/core/design_system.dart';

class PremiumMusicPlayer extends StatefulWidget {
  const PremiumMusicPlayer({super.key, required this.player});
  final AudioPlayer player;

  @override
  State<PremiumMusicPlayer> createState() => _PremiumMusicPlayerState();
}

class _PremiumMusicPlayerState extends State<PremiumMusicPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing ?? false;

        if (playing && !_waveController.isAnimating) {
          _waveController.repeat();
        } else if (!playing && _waveController.isAnimating) {
          _waveController.stop();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(32),
            boxShadow: PremiumDesign.softShadow,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPlayButton(playing, processingState),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                height: 30,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    animation: _waveController,
                    color: PremiumDesign.radiantGold,
                    isAnimating: playing,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayButton(bool playing, ProcessingState? processingState) {
    if (processingState == ProcessingState.buffering ||
        processingState == ProcessingState.loading) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: PremiumDesign.radiantGold),
      );
    }

    return GestureDetector(
      onTap: () {
        if (playing) {
          widget.player.pause();
        } else {
          widget.player.play();
        }
      },
      child: AnimatedContainer(
        duration: PremiumDesign.fast,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: PremiumDesign.radiantGold.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: PremiumDesign.radiantGold,
          size: 28,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {

  _WaveformPainter({
    required this.animation,
    required this.color,
    required this.isAnimating,
  }) : super(repaint: animation);
  final Animation<double> animation;
  final Color color;
  final bool isAnimating;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const int barCount = 15;
    final double spacing = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      double heightFactor = 0.2 +
          0.8 * math.sin((animation.value * 2 * math.pi) + (i * 0.5)).abs();
      if (!isAnimating) heightFactor = 0.2;

      final barHeight = size.height * heightFactor;
      final x = i * spacing + (spacing / 2);

      canvas.drawLine(
        Offset(x, (size.height - barHeight) / 2),
        Offset(x, (size.height + barHeight) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => isAnimating;
}
