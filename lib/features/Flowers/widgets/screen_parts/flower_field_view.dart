import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_themed.dart';

class FlowerFieldView extends StatelessWidget {
  const FlowerFieldView({
    super.key,
    required this.flowerControllers,
    required this.sparkleControllers,
    required this.entranceController,
    required this.sparkleBurstController,
    required this.animationStyle,
    required this.theme,
  });

  final List<AnimationController> flowerControllers;
  final List<AnimationController> sparkleControllers;
  final AnimationController entranceController;
  final AnimationController sparkleBurstController;
  final FlowerAnimationStyle animationStyle;
  final FlowerTheme theme;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Stack(
      children: [
        // Brillos (Sparkles)
        ...List.generate(
          sparkleControllers.length,
          (index) => AnimatedBuilder(
            animation: sparkleControllers[index],
            builder: (context, _) => _Sparkle(
              index: index,
              controller: sparkleControllers[index],
              burstController: sparkleBurstController,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
        ),

        // Flores Interactivas
        ...List.generate(
          flowerControllers.length,
          (index) => AnimatedBuilder(
            animation: Listenable.merge(
                [flowerControllers[index], entranceController]),
            builder: (context, _) => _PositionedFlower(
              index: index,
              controller: flowerControllers[index],
              entranceController: entranceController,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              animationStyle: animationStyle,
              theme: theme,
              onTap: () {
                HapticFeedback.lightImpact();
                sparkleBurstController.forward(from: 0);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.index,
    required this.controller,
    required this.burstController,
    required this.screenWidth,
    required this.screenHeight,
  });

  final int index;
  final AnimationController controller;
  final AnimationController burstController;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    final x = math.Random(index * 997).nextDouble() * screenWidth;
    final y = screenHeight * 0.15 +
        math.Random(index * 1337).nextDouble() * (screenHeight * 0.35);

    return AnimatedBuilder(
      animation: burstController,
      builder: (context, _) {
        final baseSize = 2.0 + controller.value * 3.0;
        final baseOpacity = 0.2 + controller.value * 0.6;
        final burst = 1.0 + 0.8 * burstController.value;
        final sizeDot = baseSize * burst;
        final opacity =
            (baseOpacity * (1.0 + 1.0 * burstController.value)).clamp(0.0, 1.0);

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
    );
  }
}

class _PositionedFlower extends StatelessWidget {
  const _PositionedFlower({
    required this.index,
    required this.controller,
    required this.entranceController,
    required this.screenWidth,
    required this.screenHeight,
    required this.animationStyle,
    required this.theme,
    required this.onTap,
  });

  final int index;
  final AnimationController controller;
  final AnimationController entranceController;
  final double screenWidth;
  final double screenHeight;
  final FlowerAnimationStyle animationStyle;
  final FlowerTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rnd = math.Random(index);
    final baseX = rnd.nextDouble() * screenWidth;
    final targetY =
        screenHeight * 0.45 + rnd.nextDouble() * (screenHeight * 0.4);

    final tEntrance = entranceController.value;
    final entranceY = (1.0 - tEntrance) * 100;
    final entranceBlur = (1.0 - tEntrance) * 10;
    final entranceScale = 0.8 + 0.2 * tEntrance;
    final entranceOpacity =
        const Interval(0.2, 1.0, curve: Curves.easeOut).transform(tEntrance);

    double scale = entranceScale;
    double angle = 0.0;
    double swayX = 0.0;

    final t = controller.value;
    switch (animationStyle) {
      case FlowerAnimationStyle.pulse:
        scale *= 0.95 + math.sin(t * 2 * math.pi) * 0.06;
        break;
      case FlowerAnimationStyle.spin:
        angle = math.sin(t * 2 * math.pi) * 0.35;
        scale *= 0.98 + math.sin(t * 2 * math.pi) * 0.02;
        break;
      case FlowerAnimationStyle.sway:
        swayX = math.sin(t * 2 * math.pi + index) * 14.0;
        scale *= 0.98 + math.sin(t * 2 * math.pi) * 0.02;
        break;
    }

    final parallaxX = (math.sin(t * 0.5 * math.pi) * 5.0).abs();

    return Positioned(
      left: baseX + swayX + parallaxX,
      top: targetY + entranceY,
      child: ImageFiltered(
        imageFilter:
            ImageFilter.blur(sigmaX: entranceBlur, sigmaY: entranceBlur),
        child: Opacity(
          opacity: entranceOpacity,
          child: _InteractiveFlower(
            angle: angle,
            scale: scale,
            theme: theme,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _InteractiveFlower extends StatefulWidget {
  const _InteractiveFlower({
    required this.angle,
    required this.scale,
    required this.theme,
    required this.onTap,
  });

  final double angle;
  final double scale;
  final FlowerTheme theme;
  final VoidCallback onTap;

  @override
  State<_InteractiveFlower> createState() => _InteractiveFlowerState();
}

class _InteractiveFlowerState extends State<_InteractiveFlower> {
  bool _isTouched = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTouched = true),
      onTapUp: (_) {
        setState(() => _isTouched = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isTouched = false),
      child: AnimatedContainer(
        duration: PremiumDesign.fast,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          boxShadow: _isTouched
              ? [
                  BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 30,
                      spreadRadius: 5),
                  BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2),
                ]
              : null,
        ),
        child: Transform.rotate(
          angle: widget.angle,
          child: Transform.scale(
            scale: widget.scale * (_isTouched ? 1.25 : 1.0),
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
  }
}
