import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/daily_inspiration.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

class GreenhousePage extends StatefulWidget {
  const GreenhousePage({super.key});

  @override
  State<GreenhousePage> createState() => _GreenhousePageState();
}

class _GreenhousePageState extends State<GreenhousePage>
    with SingleTickerProviderStateMixin {
  final _garden = sl<GardenService>();
  late final List<DateTime> _days = _garden.bloomDays.reversed.toList();
  late final AnimationController _sway =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  int? _selectedIndex;

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: LuminousBackground()),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Text('Invernadero',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: _warmWhite,
                          shadows: [
                            Shadow(color: _gold.withAlpha(120), blurRadius: 24)
                          ],
                        )),
                    const SizedBox(height: 4),
                    Text('Tus flores y recuerdos de cada día',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: _warmWhite.withAlpha(170))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _days.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no tienes flores.\nPlanta tu primera frase hoy 🌱',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                              color: _warmWhite.withAlpha(160), height: 1.5),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: _days.length,
                        itemBuilder: (context, i) => _FlowerCell(
                          day: _days[i],
                          sway: _sway,
                          index: i,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() =>
                                _selectedIndex = _selectedIndex == i ? null : i);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (_selectedIndex != null)
          _MemoryOverlay(
            day: _days[_selectedIndex!],
            onDismiss: () => setState(() => _selectedIndex = null),
          ),
      ],
    );
  }
}

class _FlowerCell extends StatelessWidget {
  const _FlowerCell({
    required this.day,
    required this.sway,
    required this.index,
    required this.onTap,
  });
  final DateTime day;
  final AnimationController sway;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final variant = FlowerVariant.fromSeed(
        day.year * 10000 + day.month * 100 + day.day);
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        dark: true,
        radius: 20,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: sway,
                builder: (context, _) => GrowingFlower(
                  variant: variant,
                  progress: 1.0,
                  sway: math.sin(sway.value * 2 * math.pi + index * 0.7),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day} ${months[day.month]}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _gold),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryOverlay extends StatefulWidget {
  const _MemoryOverlay({required this.day, required this.onDismiss});
  final DateTime day;
  final VoidCallback onDismiss;

  @override
  State<_MemoryOverlay> createState() => _MemoryOverlayState();
}

class _MemoryOverlayState extends State<_MemoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();
  late final Animation<double> _scale = CurvedAnimation(
      parent: _ctrl, curve: Curves.easeOutBack);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = sl<PersonalizationService>().getUserName() ?? '';
    final inspiration =
        DailyInspiration.forToday(name, mood: Mood.calm, now: widget.day);
    final months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GlassCard(
                dark: true,
                glow: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.day.day} de ${months[widget.day.month]}, ${widget.day.year}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: _gold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${inspiration.quote}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: _warmWhite),
                    ),
                    if (inspiration.author != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('— ${inspiration.author}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _gold.withAlpha(200))),
                      ),
                    const SizedBox(height: 20),
                    Text(inspiration.greeting,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: _warmWhite.withAlpha(180))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
