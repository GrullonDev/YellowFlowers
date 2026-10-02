import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';

enum ParticleKind { petal, heart, sparkle }

/// Dispara ráfagas de partículas desde fuera del [ParticleLayer].
class ParticleBurstController extends ChangeNotifier {
  Offset? _origin;
  ParticleKind _kind = ParticleKind.heart;

  /// [origin] en coordenadas relativas (0..1). Por defecto, el centro.
  void burst({
    Offset origin = const Offset(0.5, 0.45),
    ParticleKind kind = ParticleKind.heart,
  }) {
    _origin = origin;
    _kind = kind;
    notifyListeners();
  }
}

/// Capa de partículas ligera (un solo CustomPainter): pétalos que caen,
/// corazones que flotan y destellos que titilan.
class ParticleLayer extends StatefulWidget {
  const ParticleLayer({
    super.key,
    this.mood = Mood.joy,
    this.controller,
    this.density = 1.0,
  });

  final Mood mood;
  final ParticleBurstController? controller;
  final double density;

  @override
  State<ParticleLayer> createState() => _ParticleLayerState();
}

class _Particle {
  _Particle({
    required this.kind,
    required this.pos,
    required this.vel,
    required this.size,
    required this.color,
    required this.phase,
    this.rotation = 0,
    this.spin = 0,
    this.life,
  });

  final ParticleKind kind;
  Offset pos;
  Offset vel;
  final double size;
  final Color color;
  final double phase;
  double rotation;
  final double spin;

  /// Segundos restantes (solo para partículas de ráfaga).
  double? life;
  double age = 0;
}

class _ParticleLayerState extends State<ParticleLayer>
    with SingleTickerProviderStateMixin {
  static const _petalColors = [
    Color(0xFFFFD54F),
    Color(0xFFFFCA28),
    Color(0xFFFFE082),
  ];
  static const _heartColors = [
    Color(0xFFFF6F91),
    Color(0xFFFF8FAB),
    Color(0xFFFFB3C6),
  ];

  final _rnd = math.Random();
  final _particles = <_Particle>[];
  final _frame = ValueNotifier<int>(0);
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    widget.controller?.addListener(_onBurst);
  }

  @override
  void didUpdateWidget(covariant ParticleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onBurst);
      widget.controller?.addListener(_onBurst);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onBurst);
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  /// Proporción petal/heart/sparkle según el mood.
  (int, int, int) get _mix {
    final d = widget.density;
    switch (widget.mood) {
      case Mood.joy:
        return ((18 * d).round(), (5 * d).round(), (22 * d).round());
      case Mood.calm:
        return ((10 * d).round(), (4 * d).round(), (32 * d).round());
      case Mood.passion:
        return ((10 * d).round(), (16 * d).round(), (18 * d).round());
    }
  }

  void _seed() {
    _particles.removeWhere((p) => p.life == null);
    final (petals, hearts, sparkles) = _mix;
    for (var i = 0; i < petals; i++) {
      _particles.add(_spawn(ParticleKind.petal, randomY: true));
    }
    for (var i = 0; i < hearts; i++) {
      _particles.add(_spawn(ParticleKind.heart, randomY: true));
    }
    for (var i = 0; i < sparkles; i++) {
      _particles.add(_spawn(ParticleKind.sparkle, randomY: true));
    }
  }

  _Particle _spawn(ParticleKind kind, {bool randomY = false}) {
    final w = _size.width, h = _size.height;
    final x = _rnd.nextDouble() * w;
    switch (kind) {
      case ParticleKind.petal:
        return _Particle(
          kind: kind,
          pos: Offset(x, randomY ? _rnd.nextDouble() * h : -20),
          vel: Offset(0, 28 + _rnd.nextDouble() * 34),
          size: 8 + _rnd.nextDouble() * 9,
          color: _petalColors[_rnd.nextInt(_petalColors.length)],
          phase: _rnd.nextDouble() * math.pi * 2,
          rotation: _rnd.nextDouble() * math.pi,
          spin: (_rnd.nextDouble() - 0.5) * 2.4,
        );
      case ParticleKind.heart:
        return _Particle(
          kind: kind,
          pos: Offset(x, randomY ? _rnd.nextDouble() * h : h + 20),
          vel: Offset(0, -(18 + _rnd.nextDouble() * 26)),
          size: 8 + _rnd.nextDouble() * 10,
          color: _heartColors[_rnd.nextInt(_heartColors.length)],
          phase: _rnd.nextDouble() * math.pi * 2,
        );
      case ParticleKind.sparkle:
        return _Particle(
          kind: kind,
          pos: Offset(x, _rnd.nextDouble() * h),
          vel: Offset((_rnd.nextDouble() - 0.5) * 6, -2 - _rnd.nextDouble() * 6),
          size: 2 + _rnd.nextDouble() * 3.5,
          color: Colors.white,
          phase: _rnd.nextDouble() * math.pi * 2,
        );
    }
  }

  void _onBurst() {
    final c = widget.controller;
    if (c == null || c._origin == null || _size.isEmpty) return;
    final origin =
        Offset(c._origin!.dx * _size.width, c._origin!.dy * _size.height);
    for (var i = 0; i < 26; i++) {
      final angle = _rnd.nextDouble() * math.pi * 2;
      final speed = 90 + _rnd.nextDouble() * 180;
      final kind = i.isEven ? c._kind : ParticleKind.sparkle;
      _particles.add(_Particle(
        kind: kind,
        pos: origin,
        vel: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 60),
        size: kind == ParticleKind.sparkle
            ? 3 + _rnd.nextDouble() * 3
            : 10 + _rnd.nextDouble() * 10,
        color: kind == ParticleKind.heart
            ? _heartColors[_rnd.nextInt(_heartColors.length)]
            : kind == ParticleKind.petal
                ? _petalColors[_rnd.nextInt(_petalColors.length)]
                : Colors.white,
        phase: _rnd.nextDouble() * math.pi * 2,
        spin: (_rnd.nextDouble() - 0.5) * 6,
        life: 1.6 + _rnd.nextDouble() * 0.8,
      ));
    }
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    if (_size.isEmpty) return;
    final h = _size.height, w = _size.width;
    final t = elapsed.inMicroseconds / 1e6;

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.age += dt;
      if (p.life != null) {
        // Ráfaga: gravedad suave + rozamiento
        p.vel = Offset(p.vel.dx * 0.97, p.vel.dy * 0.97 + 140 * dt);
        p.pos += p.vel * dt;
        p.rotation += p.spin * dt;
        p.life = p.life! - dt;
        if (p.life! <= 0) _particles.removeAt(i);
        continue;
      }
      final sway = math.sin(t * 1.3 + p.phase);
      switch (p.kind) {
        case ParticleKind.petal:
          p.pos += Offset(p.vel.dx + sway * 22, p.vel.dy) * dt;
          p.rotation += p.spin * dt;
          if (p.pos.dy > h + 30) _particles[i] = _spawn(ParticleKind.petal);
        case ParticleKind.heart:
          p.pos += Offset(sway * 16, p.vel.dy) * dt;
          if (p.pos.dy < -30) _particles[i] = _spawn(ParticleKind.heart);
        case ParticleKind.sparkle:
          p.pos += p.vel * dt;
          if (p.pos.dy < -10 || p.pos.dx < -10 || p.pos.dx > w + 10) {
            _particles[i] = _spawn(ParticleKind.sparkle)
              ..pos = Offset(_rnd.nextDouble() * w, h + 5);
          }
      }
    }
    _frame.value++;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(builder: (context, constraints) {
          final newSize = constraints.biggest;
          if (newSize != _size) {
            _size = newSize;
            _seed();
          }
          return CustomPaint(
            size: newSize,
            painter: _ParticlePainter(_particles, _frame),
          );
        }),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, Listenable repaint)
      : super(repaint: repaint);

  final List<_Particle> particles;
  final _paint = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final fade = p.life == null ? 1.0 : (p.life! / 0.6).clamp(0.0, 1.0);
      switch (p.kind) {
        case ParticleKind.petal:
          _paint
            ..color = p.color.withValues(alpha: 0.75 * fade)
            ..maskFilter = null;
          canvas.save();
          canvas.translate(p.pos.dx, p.pos.dy);
          canvas.rotate(p.rotation);
          // Escala horizontal simula el giro 3D del pétalo
          canvas.scale(0.55 + 0.45 * math.cos(p.rotation * 1.7).abs(), 1);
          canvas.drawOval(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 1.7),
              _paint);
          canvas.restore();
        case ParticleKind.heart:
          final pulse = 1 + 0.08 * math.sin(p.age * 5 + p.phase);
          _paint
            ..color = p.color.withValues(alpha: 0.7 * fade)
            ..maskFilter = null;
          canvas.save();
          canvas.translate(p.pos.dx, p.pos.dy);
          canvas.rotate(p.life == null ? 0.15 * math.sin(p.phase) : p.rotation);
          canvas.drawPath(_heartPath(p.size * pulse), _paint);
          canvas.restore();
        case ParticleKind.sparkle:
          final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(p.age * 4 + p.phase));
          final r = p.size * twinkle;
          _paint
            ..color = Colors.white.withValues(alpha: 0.35 * twinkle * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawCircle(p.pos, r * 2.2, _paint);
          _paint
            ..color = p.color.withValues(alpha: 0.95 * twinkle * fade)
            ..maskFilter = null;
          canvas.drawPath(_starPath(p.pos, r * 1.8), _paint);
      }
    }
  }

  Path _heartPath(double s) {
    return Path()
      ..moveTo(0, s * 0.35)
      ..cubicTo(-s * 0.95, -s * 0.2, -s * 0.4, -s * 0.95, 0, -s * 0.38)
      ..cubicTo(s * 0.4, -s * 0.95, s * 0.95, -s * 0.2, 0, s * 0.35)
      ..close();
  }

  /// Estrella de 4 puntas.
  Path _starPath(Offset c, double r) {
    final k = r * 0.22;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
