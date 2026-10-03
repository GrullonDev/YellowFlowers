import 'dart:ui';
import 'package:flutter/material.dart';

/// Tarjeta con efecto glassmorphism: desenfoque del fondo, borde de luz
/// y un brillo blanco en la parte superior.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.dark = false,
    this.padding = const EdgeInsets.all(22),
    this.radius = 28,
    this.glow = false,
  });

  final Widget child;
  final bool dark;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Halo dorado alrededor de la tarjeta.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (glow)
            BoxShadow(
              color: const Color(0xFFFFC107).withAlpha(dark ? 55 : 40),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withAlpha(dark ? 70 : 18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [Colors.white.withAlpha(34), Colors.white.withAlpha(10)]
                    : [
                        Colors.white.withAlpha(225),
                        Colors.white.withAlpha(170)
                      ],
              ),
              border: Border.all(
                color: dark
                    ? const Color(0xFFFFE082).withAlpha(60)
                    : Colors.white.withAlpha(200),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                // Reflejo de luz en el borde superior
                Positioned(
                  top: -1,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1.2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.white.withAlpha(dark ? 140 : 255),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
