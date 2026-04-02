import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:yellow_flowers/features/flowers/models/default_messages.dart';

enum StoryCardStyle { romantic, minimal, elegant, vintage, premium }

class StoryCard extends StatelessWidget {
  StoryCard({
    super.key,
    required this.name,
    required this.message,
    required this.qrUrl,
    this.style = StoryCardStyle.premium,
    this.topColor = const Color(0xFFFFF7C2),
    this.bottomColor = const Color(0xFFFFB3C6),
    this.fancyName = false,
    this.width = 1080,
    this.height = 1920,
    GlobalKey? boundaryKey,
  }) : boundaryKey = boundaryKey ?? GlobalKey();

  final String name;
  final String message;
  final String qrUrl;
  final StoryCardStyle style;
  final Color topColor;
  final Color bottomColor;
  final bool fancyName;
  final double width;
  final double height;
  final GlobalKey boundaryKey;

  @override
  Widget build(BuildContext context) {
    final finalMessage =
        (message.trim().isEmpty) ? DefaultMessages.getRandom() : message;

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topColor,
              bottomColor.withAlpha(200),
              bottomColor,
            ],
            stops: const [0.0, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Texture Layer
            Positioned.fill(
              child: CustomPaint(
                painter: _GrainPainter(
                  opacity: style == StoryCardStyle.vintage ? 0.08 : 0.04,
                ),
              ),
            ),

            // Subtle Premium Bubbles (Glassmorphism)
            ..._buildPremiumBubbles(),

            // Content
            Padding(
              padding: const EdgeInsets.all(80),
              child: Column(
                children: [
                  _buildHeader(),
                  const Spacer(flex: 1),
                  _buildBody(finalMessage),
                  const Spacer(flex: 2),
                  _buildFooter(),
                ],
              ),
            ),

            // Watermark
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    'flores amarillas • tu jardín emocional',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                      color: const Color(0xFF3E2723).withAlpha(120),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPremiumBubbles() {
    return [
      Positioned(
        top: -100,
        left: -100,
        child: _BlurBubble(size: 400, color: Colors.white.withAlpha(80)),
      ),
      Positioned(
        bottom: 200,
        right: -150,
        child: _BlurBubble(size: 500, color: bottomColor.withAlpha(40)),
      ),
    ];
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          '✨🌻✨',
          style: TextStyle(
              fontSize: 42, color: const Color(0xFF3E2723).withAlpha(180)),
        ),
      ],
    );
  }

  Widget _buildBody(String messageToDisplay) {
    const textColor = Color(0xFF3E2723);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: Colors.white.withAlpha(150), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para $name 💛',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 68,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                messageToDisplay,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: textColor.withAlpha(200),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: 120,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      textColor.withAlpha(60),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            width: 180,
            height: 180,
            child: PrettyQrView.data(
              data: qrUrl,
              decoration: const PrettyQrDecoration(
                shape: PrettyQrSmoothSymbol(color: Color(0xFF3E2723)),
                image: PrettyQrDecorationImage(
                  image: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/1047/1047711.png'),
                  scale: 0.3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Escanea para florecer',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: const Color(0xFF3E2723).withAlpha(120),
          ),
        ),
      ],
    );
  }

  static Future<Uint8List?> exportPng(GlobalKey boundaryKey,
      {double pixelRatio = 3.0}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({this.opacity = 0.04});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((opacity * 255).toInt());
    final rnd = math.Random(42);
    for (int i = 0; i < 6000; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
