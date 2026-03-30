import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yellow_flowers/core/design_system.dart';

class PremiumLoading extends StatelessWidget {
  const PremiumLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset(
              'assets/lottie/flower_bloom.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: PremiumDesign.s16),
          Text(
            'Cultivando momentos...',
            style: PremiumDesign.sansLabel.copyWith(
              color: PremiumDesign.radiantGold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.color,
    this.padding,
    this.borderRadius,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? PremiumDesign.premiumRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(PremiumDesign.s24),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ?? PremiumDesign.premiumRadius,
            border: Border.all(
              color: (color ?? Colors.white).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PremiumModal extends StatelessWidget {

  const PremiumModal({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });
  final String title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        shape:
            RoundedRectangleBorder(borderRadius: PremiumDesign.premiumRadius),
        title: Text(
          title,
          style: PremiumDesign.serifSubHeading.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: content,
        actions: actions,
        actionsPadding: const EdgeInsets.all(PremiumDesign.s16),
      ),
    );
  }
}
