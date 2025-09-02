import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class StoryCard extends StatelessWidget {
  StoryCard({
    super.key,
    required this.name,
    required this.message,
    required this.qrUrl,
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
        decoration: const BoxDecoration(
          // colors injected below via DecoratedBox
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
          ),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                '✨🌻💛',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$name, $message',
                textAlign: TextAlign.center,
                style: (fancyName
                        ? GoogleFonts.raleway().copyWith(
                            fontStyle: FontStyle.italic)
                        : GoogleFonts.poppins())
                    .copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              // Simple flower field decoration at the bottom of story
              SizedBox(
                width: double.infinity,
                height: height * 0.28,
                child: CustomPaint(
                  painter: _StoryFlowersPainter(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: PrettyQrView.data(
                        data: qrUrl,
                        decoration: const PrettyQrDecoration(
                          quietZone: PrettyQrQuietZone.standart,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Escanéame para abrir la app',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
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

class _StoryFlowersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF5A8F5D)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final head = Paint()..color = const Color(0xFFE57373);
    final rnd = List<double>.generate(12, (i) => (i + 1) / 13.0);
    for (var i = 0; i < rnd.length; i++) {
      final x = 20 + i * (size.width - 40) / (rnd.length - 1);
      final h = size.height * (0.35 + 0.6 * (i % 3) / 3);
      final base = Offset(x, size.height);
      final top = Offset(x, size.height - h);
      canvas.drawLine(base, top, stem);
      canvas.drawCircle(top + const Offset(0, 10), 22, head);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
