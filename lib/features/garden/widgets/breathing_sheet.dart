import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _warmWhite = Color(0xFFFFF8E1);

/// Respiración guiada 4-4-6: inhala, sostén y exhala, durante [_cycles] ciclos.
Future<void> showBreathingSheet(BuildContext context, {required Color color}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1030),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _BreathingSheet(color: color),
  );
}

const _inhale = 4, _hold = 4, _exhale = 6, _cycles = 4;
const _cycleSeconds = _inhale + _hold + _exhale;

class _BreathingSheet extends StatefulWidget {
  const _BreathingSheet({required this.color});
  final Color color;

  @override
  State<_BreathingSheet> createState() => _BreathingSheetState();
}

class _BreathingSheetState extends State<_BreathingSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycleSeconds * _cycles),
  )
    ..addListener(_onTick)
    ..forward();

  String _phase = '';

  void _onTick() {
    final phase = _phaseAt(_secondInCycle).$1;
    if (phase != _phase) {
      // Una vibración suave en cada cambio de fase guía sin mirar la pantalla.
      if (_phase.isNotEmpty) HapticFeedback.lightImpact();
      setState(() => _phase = phase);
    }
  }

  double get _secondInCycle =>
      (_ctrl.value * _cycleSeconds * _cycles) % _cycleSeconds;

  /// (texto de la fase, escala del círculo entre 0 y 1).
  (String, double) _phaseAt(double s) {
    if (_ctrl.isCompleted) return ('Lo hiciste muy bien', 0.6);
    if (s < _inhale) return ('Inhala', s / _inhale);
    if (s < _inhale + _hold) return ('Sostén', 1);
    return ('Exhala', 1 - (s - _inhale - _hold) / _exhale);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _warmWhite.withAlpha(60),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Text('Respira conmigo',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _warmWhite)),
            const SizedBox(height: 6),
            Text('Sigue el círculo. Un minuto solo para ti.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: _warmWhite.withAlpha(160))),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final scale = 0.45 + 0.55 * _phaseAt(_secondInCycle).$2;
                  return Center(
                    child: Container(
                      width: 220 * scale,
                      height: 220 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          color.withAlpha(200),
                          color.withAlpha(60),
                        ]),
                        boxShadow: [
                          BoxShadow(
                              color: color.withAlpha(90),
                              blurRadius: 40 * scale,
                              spreadRadius: 4)
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(_phase,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => _ctrl.isCompleted
                  ? FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: color),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Me siento mejor'),
                    )
                  : LinearProgressIndicator(
                      value: _ctrl.value,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                      color: color,
                      backgroundColor: _warmWhite.withAlpha(25),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
