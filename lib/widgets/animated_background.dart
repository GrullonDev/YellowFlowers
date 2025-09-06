import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable animated background widget with gradient and floating decorative elements.
/// This widget provides a consistent animated background across different screens.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.child,
    this.topColorBegin = const Color(0xFFFFF7C2),
    this.topColorEnd = const Color(0xFFFFE8A3),
    this.bottomColorBegin = const Color(0xFFFFD3B6),
    this.bottomColorEnd = const Color(0xFFFFB347),
    this.decorationCount = 8,
    this.decorationOpacity = 0.1,
  });

  /// The child widget to display on top of the animated background.
  final Widget? child;

  /// Starting color for the top of the gradient.
  final Color topColorBegin;

  /// Ending color for the top of the gradient.
  final Color topColorEnd;

  /// Starting color for the bottom of the gradient.
  final Color bottomColorBegin;

  /// Ending color for the bottom of the gradient.
  final Color bottomColorEnd;

  /// Number of decorative floating elements.
  final int decorationCount;

  /// Base opacity for decorative elements.
  final double decorationOpacity;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _topColorAnim = ColorTween(
      begin: widget.topColorBegin,
      end: widget.topColorEnd,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: widget.bottomColorBegin,
      end: widget.bottomColorEnd,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) => Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _topColorAnim.value ?? widget.topColorBegin,
                  _bottomColorAnim.value ?? widget.bottomColorBegin,
                ],
              ),
            ),
          ),
          // Soft decorative hearts/petals
          ...List.generate(widget.decorationCount, (i) {
            final rnd = math.Random(i + 42);
            final dx = rnd.nextDouble();
            final dy = rnd.nextDouble();
            final drift =
                math.sin((_bgController.value * 2 * math.pi) + i) * 10;
            final isHeart = i.isEven;
            return Positioned(
              left: dx * MediaQuery.of(context).size.width,
              top: dy * MediaQuery.of(context).size.height / 2 + drift,
              child: Opacity(
                opacity: widget.decorationOpacity +
                    widget.decorationOpacity *
                        math
                            .sin(_bgController.value * 2 * math.pi + i)
                            .abs(),
                child: Transform.rotate(
                  angle:
                      math.sin(_bgController.value * 2 * math.pi + i) * 0.2,
                  child: Icon(
                    isHeart ? Icons.favorite : Icons.local_florist,
                    color: isHeart
                        ? Colors.pinkAccent
                        : const Color(0xFFFFE07D),
                    size: 18 + rnd.nextDouble() * 10,
                  ),
                ),
              ),
            );
          }),
          // Child content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
