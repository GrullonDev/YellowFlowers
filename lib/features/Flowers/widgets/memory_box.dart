import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';

/// Abre la "Caja de recuerdos": sobres digitales con razones para sonreír.
/// [onEnvelopeOpened] se invoca cada vez que se abre un sobre (p. ej. para
/// lanzar una ráfaga de partículas).
Future<void> showMemoryBox(
  BuildContext context, {
  required String recipient,
  VoidCallback? onEnvelopeOpened,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MemoryBoxSheet(
      recipient: recipient,
      onEnvelopeOpened: onEnvelopeOpened,
    ),
  );
}

class _MemoryBoxSheet extends StatefulWidget {
  const _MemoryBoxSheet({required this.recipient, this.onEnvelopeOpened});
  final String recipient;
  final VoidCallback? onEnvelopeOpened;

  @override
  State<_MemoryBoxSheet> createState() => _MemoryBoxSheetState();
}

class _MemoryBoxSheetState extends State<_MemoryBoxSheet> {
  late final List<(String, String)> _reasons =
      SmileReasons.pick(widget.recipient);
  final Set<int> _opened = {};

  void _open(int i) {
    if (_opened.contains(i)) return;
    HapticFeedback.mediumImpact();
    setState(() => _opened.add(i));
    widget.onEnvelopeOpened?.call();
  }

  @override
  Widget build(BuildContext context) {
    final allOpen = _opened.length == _reasons.length;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: PremiumDesign.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumDesign.secondaryText.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('CAJA DE RECUERDOS 💌',
                textAlign: TextAlign.center, style: PremiumDesign.sansLabel),
            const SizedBox(height: 8),
            Text(
              'Razones para sonreír, ${widget.recipient}',
              textAlign: TextAlign.center,
              style: PremiumDesign.serifHeading,
            ),
            const SizedBox(height: 6),
            Text(
              allOpen
                  ? '¡Abriste todos los sobres! 💛'
                  : 'Toca un sobre para abrirlo · ${_opened.length}/${_reasons.length}',
              textAlign: TextAlign.center,
              style: PremiumDesign.sansBody.copyWith(
                  fontSize: 13, color: PremiumDesign.secondaryText),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reasons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (_, i) => _Envelope(
                emoji: _reasons[i].$1,
                message: _reasons[i].$2,
                opened: _opened.contains(i),
                onTap: () => _open(i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Envelope extends StatelessWidget {
  const _Envelope({
    required this.emoji,
    required this.message,
    required this.opened,
    required this.onTap,
  });

  final String emoji;
  final String message;
  final bool opened;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: opened ? 1 : 0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        builder: (context, t, _) {
          final showBack = t >= 0.5;
          // Volteo 3D: la cara trasera se des-espeja girando otros 180°
          final angle = t * math.pi + (showBack ? math.pi : 0);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: showBack ? _back() : _front(),
          );
        },
      ),
    );
  }

  Widget _front() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFCA28)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: PremiumDesign.softShadow,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _FlapPainter())),
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE57373),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _back() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumDesign.radiantGold.withAlpha(90)),
        boxShadow: PremiumDesign.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.35,
                color: PremiumDesign.softText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dibuja la solapa en "V" del sobre.
class _FlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height * 0.5)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height * 0.5)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = Colors.white.withAlpha(35),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
