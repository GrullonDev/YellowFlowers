import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:yellow_flowers/core/design_system.dart';

class BackgroundLayer extends StatelessWidget {
  const BackgroundLayer({
    super.key,
    required this.topColor,
    required this.bottomColor,
    required this.bgAnimation,
    required this.petalAnimation,
    required this.petalSeeds,
  });

  final Color topColor;
  final Color bottomColor;
  final Animation<double> bgAnimation;
  final Animation<double> petalAnimation;
  final List<PetalSeed> petalSeeds;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Mesh Gradient (Simulated with blurred circles)
        Positioned.fill(
          child: CustomPaint(
            painter: _MeshGradientPainter(
              animation: bgAnimation,
              moodColor: topColor,
            ),
          ),
        ),

        // 2. Liquid Partículas (Refined)
        Positioned.fill(
          child: CustomPaint(
            painter: _LiquidParticlesPainter(
              animation: bgAnimation,
            ),
          ),
        ),

        // 3. Pétalos Cayendo (Premium physics)
        ...List.generate(petalSeeds.length, (i) {
          final sizeSize = MediaQuery.of(context).size;
          final screenWidth = sizeSize.width;
          final screenHeight = sizeSize.height;
          final seed = petalSeeds[i];
          final t = (petalAnimation.value + seed.phase) % 1.0;
          final y = (t * (screenHeight + 120)) - 60 + seed.startY * 40;
          final x = seed.startX * screenWidth +
              math.sin(t * seed.swayFreq * 2 * math.pi) * (seed.swayAmp * 1.5);
          final rot = t * seed.rotationSpeed * 4 * math.pi;

          return Positioned(
            left: x,
            top: y % (screenHeight + 120) - 60,
            child: Transform.rotate(
              angle: rot,
              child: _Petal(size: seed.size),
            ),
          );
        }),
      ],
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
        color: const Color(0xFFFFD54F).withAlpha(200),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          bottomRight: Radius.circular(size),
          topRight: Radius.circular(size * 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA000).withAlpha(100),
            blurRadius: 10,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
  }
}

class PetalSeed {
  PetalSeed({
    required this.startX,
    required this.startY,
    required this.swayAmp,
    required this.swayFreq,
    required this.size,
    required this.rotationSpeed,
    required this.phase,
  });
  final double startX, startY, swayAmp, swayFreq, size, rotationSpeed, phase;
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({required this.animation, required this.moodColor})
      : super(repaint: animation);
  final Animation<double> animation;
  final Color moodColor;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    // Gradient Background base
    final baseGradient = LinearGradient(
      colors: [moodColor, moodColor.withAlpha(200), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = baseGradient);

    // Simulated Mesh (Blurred Blobs)
    _drawBlob(canvas, size,
        color: PremiumDesign.mesh2.withAlpha(150),
        offset: Offset(size.width * 0.1 + math.sin(t * 1.5) * 50,
            size.height * 0.2 + math.cos(t * 1.2) * 50),
        radius: size.width * 0.8);

    _drawBlob(canvas, size,
        color: PremiumDesign.mesh3.withAlpha(120),
        offset: Offset(size.width * 0.8 + math.cos(t * 1.1) * 80,
            size.height * 0.5 + math.sin(t * 1.3) * 60),
        radius: size.width * 0.9);

    _drawBlob(canvas, size,
        color: PremiumDesign.mesh4.withAlpha(100),
        offset: Offset(size.width * 0.3 + math.cos(t * 1.4) * 60,
            size.height * 0.8 + math.sin(t * 1.6) * 70),
        radius: size.width * 0.7);
  }

  void _drawBlob(Canvas canvas, Size size,
      {required Color color, required Offset offset, required double radius}) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5);
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LiquidParticlesPainter extends CustomPainter {
  _LiquidParticlesPainter({required this.animation})
      : super(repaint: animation);
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    for (int i = 0; i < 15; i++) {
      final rnd = math.Random(i * 123);
      final x = (rnd.nextDouble() * size.width +
          math.sin(t * 2 * math.pi * 0.2 + rnd.nextDouble()) * 30);
      final y = (rnd.nextDouble() * size.height +
          math.cos(t * 2 * math.pi * 0.15 + rnd.nextDouble()) * 40);
      final s = 40 + rnd.nextDouble() * 60;
      final o = 0.03 + rnd.nextDouble() * 0.08;

      paint.color = Colors.white.withAlpha((o * 255).toInt());
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
