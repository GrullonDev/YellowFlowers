import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class CycleMusicPage extends StatefulWidget {
  const CycleMusicPage({super.key});

  @override
  State<CycleMusicPage> createState() => _CycleMusicPageState();
}

class _CycleMusicPageState extends State<CycleMusicPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _ringCtrl.forward();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleController>(
      builder: (context, model, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: PremiumDesign.softText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Mi Ciclo',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w800,
                color: PremiumDesign.softText,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded,
                    color: PremiumDesign.softText),
                tooltip: 'Configurar ciclo',
                onPressed: () => _showConfigSheet(context, model),
              ),
            ],
          ),
          body: AnimatedBackground(
            decorationCount: 8,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: PremiumDesign.s24, vertical: PremiumDesign.s8),
                child: Column(
                  children: [
                    _CycleRing(model: model, progress: _ringAnim),
                    const SizedBox(height: PremiumDesign.s32),
                    _AffirmationCard(model: model),
                    const SizedBox(height: PremiumDesign.s24),
                    _TipsSection(model: model),
                    const SizedBox(height: PremiumDesign.s32),
                    _MusicCta(model: model),
                    const SizedBox(height: PremiumDesign.s48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfigSheet(BuildContext context, CycleController model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ChangeNotifierProvider.value(
          value: model,
          child: const _CycleConfigSheet(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CYCLE RING
// ═══════════════════════════════════════════════════════════════════════════════

class _CycleRing extends StatelessWidget {
  const _CycleRing({required this.model, required this.progress});

  final CycleController model;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final configured = model.lastPeriodStart != null;
    final day = model.currentDayInCycle;
    final total = model.cycleLength;

    return Column(
      children: [
        AnimatedBuilder(
          animation: progress,
          builder: (context, _) => SizedBox(
            width: 230,
            height: 230,
            child: CustomPaint(
              painter: _RingPainter(
                cycleLength: total,
                currentDay: configured ? day : 0,
                animationValue: progress.value,
              ),
              child: Center(
                child: configured
                    ? _RingCenter(day: day, total: total, model: model)
                    : _RingSetupCenter(),
              ),
            ),
          ),
        ),
        const SizedBox(height: PremiumDesign.s16),
        if (configured) ...[
          Text(
            model.currentPhaseLabel,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumDesign.softText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Próximo periodo en ${model.daysUntilNextPeriod} días',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PremiumDesign.secondaryText,
            ),
          ),
        ] else ...[
          Text(
            'Conoce tu ciclo',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumDesign.softText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca ⚙️ arriba para configurar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PremiumDesign.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

class _RingCenter extends StatelessWidget {
  const _RingCenter(
      {required this.day, required this.total, required this.model});

  final int day;
  final int total;
  final CycleController model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(model.phaseEmoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(
          'Día $day',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: PremiumDesign.softText,
          ),
        ),
        Text(
          'de $total',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: PremiumDesign.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _RingSetupCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.spa_rounded, size: 36, color: Color(0xFFE91E8C)),
        const SizedBox(height: 6),
        Text(
          '¡Hola!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: PremiumDesign.softText,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RING PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _PhaseSegment {
  const _PhaseSegment(this.dayFrom, this.dayTo, this.color);

  final int dayFrom;
  final int dayTo;
  final Color color;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.cycleLength,
    required this.currentDay,
    required this.animationValue,
  });

  final int cycleLength;
  final int currentDay;
  final double animationValue;

  List<_PhaseSegment> _segments() => [
        const _PhaseSegment(0, 5, Color(0xFFE57373)), // Menstrual
        const _PhaseSegment(6, 11, Color(0xFFFFCA28)), // Folicular
        const _PhaseSegment(12, 16, Color(0xFFF9A825)), // Fértil
        _PhaseSegment(17, cycleLength - 6, const Color(0xFFBA68C8)), // Lútea
        _PhaseSegment(cycleLength - 5, cycleLength - 1,
            const Color(0xFF7E57C2)), // Premenstrual
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 32) / 2;
    const sw = 16.0;
    const gap = 0.025; // radians gap between segments

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    // Phase arcs
    for (final seg in _segments()) {
      if (seg.dayFrom >= cycleLength) continue;
      final safeTo = seg.dayTo.clamp(0, cycleLength - 1);
      if (safeTo < seg.dayFrom) continue;

      final startF = seg.dayFrom / cycleLength;
      final endF = (safeTo + 1) / cycleLength;
      final animatedEnd = startF + (endF - startF) * animationValue;
      if (animatedEnd <= startF) continue;

      final startAngle = -math.pi / 2 + startF * 2 * math.pi + gap;
      final sweepAngle = (animatedEnd - startF) * 2 * math.pi - gap * 2;
      if (sweepAngle <= 0) continue;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = seg.color.withValues(alpha: 0.88)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }

    // Current-day dot (fades in at the end of the animation)
    if (currentDay > 0 && animationValue > 0.75) {
      final dotOpacity = ((animationValue - 0.75) / 0.25).clamp(0.0, 1.0);
      final angle =
          -math.pi / 2 + ((currentDay - 1) / cycleLength) * 2 * math.pi;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      final dot = Offset(dx, dy);

      canvas.drawCircle(
        dot,
        11,
        Paint()
          ..color = Colors.white.withValues(alpha: dotOpacity)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        dot,
        11,
        Paint()
          ..color = const Color(0xFFE91E8C).withValues(alpha: dotOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        dot,
        4.5,
        Paint()
          ..color = const Color(0xFFE91E8C).withValues(alpha: dotOpacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.currentDay != currentDay ||
      old.cycleLength != cycleLength ||
      old.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════════
// AFFIRMATION CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _AffirmationCard extends StatelessWidget {
  const _AffirmationCard({required this.model});

  final CycleController model;

  @override
  Widget build(BuildContext context) {
    final colors = model.phaseGradientColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PremiumDesign.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PremiumDesign.premiumRadius,
        boxShadow: PremiumDesign.softShadow,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AFIRMACIÓN DEL DÍA', style: PremiumDesign.sansLabel),
          const SizedBox(height: PremiumDesign.s12),
          Text(
            model.phaseAffirmation,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: PremiumDesign.softText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: PremiumDesign.s12),
          if (model.recommendation != null)
            Text(
              model.recommendation!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: PremiumDesign.secondaryText,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIPS SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _TipsSection extends StatelessWidget {
  const _TipsSection({required this.model});

  final CycleController model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Para ti hoy', style: PremiumDesign.serifSubHeading),
        const SizedBox(height: PremiumDesign.s12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: model.phaseTips.map((tip) => _TipChip(label: tip)).toList(),
        ),
      ],
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFE91E8C).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: PremiumDesign.softText,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MUSIC CTA
// ═══════════════════════════════════════════════════════════════════════════════

class _MusicCta extends StatelessWidget {
  const _MusicCta({required this.model});

  final CycleController model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PremiumTransitions.fadeThrough(const MusicPage()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PremiumDesign.s20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF79B0), Color(0xFFE91E8C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: PremiumDesign.premiumRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E8C).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: PremiumDesign.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Música para ti',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Melodías para acompañar tu momento',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIG SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _CycleConfigSheet extends StatefulWidget {
  const _CycleConfigSheet();

  @override
  State<_CycleConfigSheet> createState() => _CycleConfigSheetState();
}

class _CycleConfigSheetState extends State<_CycleConfigSheet> {
  DateTime? _selectedDate;
  int _length = 28;

  @override
  void initState() {
    super.initState();
    final c = context.read<CycleController>();
    _selectedDate = c.lastPeriodStart;
    _length = c.cycleLength;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'Primer día del último periodo'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
            '${_selectedDate!.month.toString().padLeft(2, '0')}/'
            '${_selectedDate!.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tu ciclo',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: PremiumDesign.softText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configura tu ciclo para recibir recomendaciones personalizadas.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: PremiumDesign.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: PremiumDesign.s20),
          OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: now,
                initialDate: _selectedDate ?? now,
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text(dateLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: PremiumDesign.s16),
          Row(
            children: [
              Text(
                'Duración del ciclo:',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: PremiumDesign.softText,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _length,
                items: List.generate(15, (i) => 21 + i)
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text('$d días')))
                    .toList(),
                onChanged: (v) => setState(() => _length = v ?? 28),
              ),
            ],
          ),
          const SizedBox(height: PremiumDesign.s20),
          FilledButton.icon(
            onPressed: () async {
              final c = context.read<CycleController>();
              if (_selectedDate != null) await c.setLastPeriod(_selectedDate!);
              await c.setCycleLength(_length);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Guardar'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
