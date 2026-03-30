import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

enum StoryCardStyle { romantic, minimal, elegant, vintage }

class StoryCard extends StatelessWidget {
  StoryCard({
    super.key,
    required this.name,
    required this.message,
    required this.qrUrl,
    this.style = StoryCardStyle.romantic,
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
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: width,
        height: height,
        color: _getBgColor(),
        child: Stack(
          children: [
            if (style == StoryCardStyle.vintage)
              Positioned.fill(child: _VintageTexture()),
            
            // Texture Layer
            Positioned.fill(
              child: CustomPaint(
                painter: _GrainPainter(
                  opacity: style == StoryCardStyle.vintage ? 0.08 : 0.03,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(80),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),
                  Expanded(child: _buildBody()),
                  _buildFooter(),
                ],
              ),
            ),

            // Watermark
            Positioned(
              bottom: 40,
              right: 40,
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  'by Yellow Flowers 🌻',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor().withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBgColor() {
    switch (style) {
      case StoryCardStyle.minimal: return Colors.white;
      case StoryCardStyle.vintage: return const Color(0xFFF2E8D5);
      case StoryCardStyle.elegant: return const Color(0xFFFAFAFA);
      default: return topColor.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (style) {
      case StoryCardStyle.vintage: return const Color(0xFF4E342E);
      case StoryCardStyle.elegant: return const Color(0xFF2C3E50);
      default: return const Color(0xFF3E2723);
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        if (style == StoryCardStyle.elegant)
          Container(
            width: 80,
            height: 2,
            color: const Color(0xFFD4AF37),
            margin: const EdgeInsets.only(bottom: 20),
          ),
        Text(
          style == StoryCardStyle.minimal ? '🌻' : '✨🌻✨',
          style: TextStyle(fontSize: style == StoryCardStyle.minimal ? 48 : 36),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final textColor = _getTextColor();
    final messageStyle = _getMessageStyle(textColor);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            decoration: _getBoxDecoration(),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: _getNameStyle(textColor),
                ),
                const SizedBox(height: 32),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: messageStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration? _getBoxDecoration() {
    if (style == StoryCardStyle.minimal) return null;
    if (style == StoryCardStyle.romantic) {
      return BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: bottomColor.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      );
    }
    if (style == StoryCardStyle.elegant) {
      return BoxDecoration(
        border: Border.all(color: const Color(0xFFD4AF37), width: 3),
      );
    }
    return null;
  }

  TextStyle _getNameStyle(Color color) {
    switch (style) {
      case StoryCardStyle.minimal:
        return GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w300, color: color);
      case StoryCardStyle.elegant:
        return GoogleFonts.bodoniModa(fontSize: 56, fontWeight: FontWeight.bold, color: color);
      case StoryCardStyle.vintage:
        return GoogleFonts.playfairDisplay(fontSize: 52, fontWeight: FontWeight.w800, color: color);
      default:
        return GoogleFonts.playfairDisplay(fontSize: 64, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: color);
    }
  }

  TextStyle _getMessageStyle(Color color) {
    switch (style) {
      case StoryCardStyle.minimal:
        return GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w400, color: color, height: 1.5);
      case StoryCardStyle.elegant:
        return GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w300, color: color, height: 1.6, letterSpacing: 1.2);
      case StoryCardStyle.vintage:
        return GoogleFonts.merriweather(fontSize: 36, fontWeight: FontWeight.w400, color: color, height: 1.6);
      default:
        return GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w500, color: color, height: 1.4);
    }
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: SizedBox(
            width: 200,
            height: 200,
            child: PrettyQrView.data(
              data: qrUrl,
              decoration: const PrettyQrDecoration(
                shape: PrettyQrSmoothSymbol(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Escanea para florecer',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _getTextColor().withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  static Future<Uint8List?> exportPng(GlobalKey boundaryKey, {double pixelRatio = 3.0}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

class _VintageTexture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: Image.network(
        'https://www.transparenttextures.com/patterns/paper-fibers.png',
        repeat: ImageRepeat.repeat,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  _GrainPainter({this.opacity = 0.03});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: opacity);
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
