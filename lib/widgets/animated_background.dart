import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.child,
    this.topColorBegin,
    this.topColorEnd,
    this.bottomColorBegin,
    this.bottomColorEnd,
    this.decorationCount = 12,
    this.decorationOpacity = 0.08,
  });

  final Widget? child;
  final Color? topColorBegin;
  final Color? topColorEnd;
  final Color? bottomColorBegin;
  final Color? bottomColorEnd;
  final int decorationCount;
  final double decorationOpacity;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color topColor = widget.topColorBegin ?? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9E5));
    final Color bottomColor = widget.bottomColorBegin ?? (isDark ? const Color(0xFF121212) : const Color(0xFFFFF0F5));

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
          ),
          ...List.generate(widget.decorationCount, (i) {
            final rnd = math.Random(i + 100);
            final dx = rnd.nextDouble();
            final dy = rnd.nextDouble();
            final speed = 0.5 + rnd.nextDouble();
            final drift = math.sin((_bgController.value * 2 * math.pi * speed) + i) * 15;
            
            final opacity = (widget.decorationOpacity +
                    0.05 * math.sin(_bgController.value * math.pi + i).abs())
                .clamp(0.0, 1.0);
            
            return Positioned(
              left: dx * MediaQuery.of(context).size.width,
              top: dy * MediaQuery.of(context).size.height + drift,
              child: Opacity(
                opacity: opacity,
                child: _decorElement(i, rnd, isDark),
              ),
            );
          }),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _decorElement(int i, math.Random rnd, bool isDark) {
    final size = 20.0 + rnd.nextDouble() * 20;
    final color = isDark 
      ? Colors.white.withValues(alpha: 0.2) 
      : Colors.amber.withValues(alpha: 0.3);

    switch (i % 4) {
      case 0:
        return Icon(Icons.blur_on_rounded, color: color, size: size);
      case 1:
        return Icon(Icons.circle_outlined, color: color, size: size / 2);
      case 2:
        return Icon(Icons.auto_awesome, color: color, size: size / 1.5);
      default:
        return Icon(Icons.spa_rounded, color: color, size: size);
    }
  }
}
