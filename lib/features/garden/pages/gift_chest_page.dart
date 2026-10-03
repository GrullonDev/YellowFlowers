import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/features/garden/data/garden_service.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

class GiftChestPage extends StatefulWidget {
  const GiftChestPage({super.key});

  @override
  State<GiftChestPage> createState() => _GiftChestPageState();
}

class _GiftChestPageState extends State<GiftChestPage>
    with TickerProviderStateMixin {
  final _garden = sl<GardenService>();
  late final int _streak = _garden.currentStreak;
  late final int _totalFlowers = _garden.totalFlowers;
  late final List<_Gift> _gifts = _buildGifts();

  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward();

  late final AnimationController _sparkle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000));

  int? _openingIndex;

  List<_Gift> _buildGifts() {
    final name = sl<PersonalizationService>().getUserName() ?? 'hermosa';
    return [
      _Gift(
        streakRequired: 3,
        icon: '🎁',
        title: 'Primera Sorpresa',
        dedication: '¡$name, 3 días seguidos floreciendo! Eres constante como el sol que nunca falta.',
      ),
      _Gift(
        streakRequired: 7,
        icon: '💎',
        title: 'Joya de la Semana',
        dedication: 'Una semana entera, $name. Tu jardín brilla tanto como tú. Mereces cada pétalo.',
      ),
      _Gift(
        streakRequired: 14,
        icon: '🌟',
        title: 'Estrella Dorada',
        dedication: '14 días, $name. Tu dedicación es extraordinaria. Eres la flor más hermosa de tu propio jardín.',
      ),
      _Gift(
        streakRequired: 21,
        icon: '👑',
        title: 'Corona de Pétalos',
        dedication: '¡21 días de constancia, $name! Has creado un hábito de amor propio que nadie te puede quitar.',
      ),
      _Gift(
        streakRequired: 30,
        icon: '🏆',
        title: 'Trofeo del Mes',
        dedication: 'Un mes entero floreciendo, $name. Eres la prueba viviente de que la belleza nace de la constancia.',
      ),
      _Gift(
        streakRequired: 50,
        icon: '🦋',
        title: 'Mariposa Dorada',
        dedication: '50 días… $name, te has transformado. Como la mariposa, tu belleza interior ha encontrado alas.',
      ),
      _Gift(
        streakRequired: 100,
        icon: '🌻',
        title: 'Girasol Eterno',
        dedication: '¡100 días, $name! Eres leyenda. Tu jardín es un monumento a lo que el amor propio puede lograr.',
      ),
    ];
  }

  @override
  void dispose() {
    _entrance.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  Future<void> _openGift(int index) async {
    final gift = _gifts[index];
    if (_streak < gift.streakRequired) return;

    final prefs = sl<SharedPreferences>();
    final key = 'gift_opened_${gift.streakRequired}';
    if (prefs.getBool(key) == true) {
      _showDedication(gift);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _openingIndex = index);
    _sparkle.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 800));
    await prefs.setBool(key, true);
    if (!mounted) return;
    setState(() => _openingIndex = null);
    _showDedication(gift);
  }

  void _showDedication(_Gift gift) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => _DedicationDialog(gift: gift),
    );
  }

  bool _isOpened(_Gift gift) {
    final prefs = sl<SharedPreferences>();
    return prefs.getBool('gift_opened_${gift.streakRequired}') == true;
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.wp(20).clamp(14.0, 28.0);

    return Stack(
      children: [
        const Positioned.fill(child: LuminousBackground()),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, context.hp(12), hPad, 0),
                child: Column(
                  children: [
                    Text('Cofre de Regalos',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: context.sp(28).clamp(22, 34),
                          fontWeight: FontWeight.w700,
                          color: _warmWhite,
                          shadows: [
                            Shadow(color: _gold.withAlpha(120), blurRadius: 24)
                          ],
                        )),
                    SizedBox(height: context.hp(4)),
                    Text('Desbloquea sorpresas con tu constancia',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: context.sp(13).clamp(11, 15),
                            color: _warmWhite.withAlpha(170))),
                    SizedBox(height: context.hp(14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MiniStat(
                            icon: Icons.local_fire_department_rounded,
                            value: '$_streak',
                            label: 'racha'),
                        SizedBox(width: context.wp(20).clamp(14.0, 28.0)),
                        _MiniStat(
                            icon: Icons.filter_vintage_rounded,
                            value: '$_totalFlowers',
                            label: 'flores'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.hp(12)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      hPad, 0, hPad, context.bottomNavClearance),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _gifts.length,
                  itemBuilder: (context, i) {
                    final start = (i * 0.08).clamp(0.0, 1.0);
                    final end = (start + 0.4).clamp(0.0, 1.0);
                    final fade = CurvedAnimation(
                      parent: _entrance,
                      curve: Interval(start, end, curve: Curves.easeOut),
                    );
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(fade),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: context.hp(10)),
                          child: _GiftCard(
                            gift: _gifts[i],
                            streak: _streak,
                            opened: _isOpened(_gifts[i]),
                            opening: _openingIndex == i,
                            sparkle: _sparkle,
                            onTap: () => _openGift(i),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Gift {
  const _Gift({
    required this.streakRequired,
    required this.icon,
    required this.title,
    required this.dedication,
  });
  final int streakRequired;
  final String icon;
  final String title;
  final String dedication;
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: context.dp(18).clamp(14.0, 22.0)),
        SizedBox(width: context.wp(6)),
        Text(value,
            style: GoogleFonts.playfairDisplay(
                fontSize: context.sp(22).clamp(18, 26),
                fontWeight: FontWeight.w700,
                color: _gold)),
        SizedBox(width: context.wp(4)),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: context.sp(12).clamp(10, 14),
                color: _warmWhite.withAlpha(160))),
      ],
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({
    required this.gift,
    required this.streak,
    required this.opened,
    required this.opening,
    required this.sparkle,
    required this.onTap,
  });
  final _Gift gift;
  final int streak;
  final bool opened;
  final bool opening;
  final AnimationController sparkle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = streak >= gift.streakRequired;
    final progress = unlocked
        ? 1.0
        : (streak / gift.streakRequired).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Stack(
        children: [
          GlassCard(
            dark: true,
            radius: context.dp(22).clamp(16.0, 26.0),
            glow: unlocked && !opened,
            padding: EdgeInsets.symmetric(
                horizontal: context.wp(18).clamp(12.0, 22.0),
                vertical: context.hp(14).clamp(10.0, 18.0)),
            child: Row(
              children: [
                AnimatedScale(
                  scale: opening ? 1.4 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  child: Text(gift.icon,
                      style: TextStyle(fontSize: context.sp(36).clamp(28, 44))),
                ),
                SizedBox(width: context.wp(16).clamp(10.0, 20.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gift.title,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(15).clamp(13, 18),
                              fontWeight: FontWeight.w700,
                              color: unlocked
                                  ? _warmWhite
                                  : _warmWhite.withAlpha(100))),
                      SizedBox(height: context.hp(4)),
                      if (!unlocked) ...[
                        Text('${gift.streakRequired} días seguidos',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(12).clamp(10, 14),
                                color: _warmWhite.withAlpha(120))),
                        SizedBox(height: context.hp(6)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: context.hp(6).clamp(4.0, 8.0),
                            backgroundColor: Colors.white.withAlpha(20),
                            valueColor: const AlwaysStoppedAnimation(_gold),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),
                        Text('$streak / ${gift.streakRequired}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(10).clamp(8, 12),
                                color: _warmWhite.withAlpha(100))),
                      ] else
                        Text(
                          opened ? 'Toca para releer' : '¡Desbloqueado! Toca para abrir',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(12).clamp(10, 14),
                              fontWeight: FontWeight.w600,
                              color: opened
                                  ? _warmWhite.withAlpha(140)
                                  : _gold),
                        ),
                    ],
                  ),
                ),
                if (unlocked)
                  Icon(
                    opened
                        ? Icons.auto_awesome_rounded
                        : Icons.card_giftcard_rounded,
                    color: opened ? _gold.withAlpha(120) : _gold,
                    size: context.dp(24).clamp(20.0, 28.0),
                  ),
                if (!unlocked)
                  Icon(Icons.lock_rounded,
                      color: _warmWhite.withAlpha(60),
                      size: context.dp(20).clamp(16.0, 24.0)),
              ],
            ),
          ),
          if (opening)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: sparkle,
                builder: (context, _) => CustomPaint(
                  painter: _SparklePainter(sparkle.value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final rnd = math.Random(42);
    final paint = Paint()..color = _gold.withAlpha(((1 - t) * 200).toInt());
    final center = Offset(size.width * 0.15, size.height * 0.5);
    for (var i = 0; i < 20; i++) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final dist = t * (40 + rnd.nextDouble() * 60);
      final r = 2.0 + rnd.nextDouble() * 3 * (1 - t);
      canvas.drawCircle(
        center + Offset(math.cos(angle) * dist, math.sin(angle) * dist),
        r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}

class _DedicationDialog extends StatefulWidget {
  const _DedicationDialog({required this.gift});
  final _Gift gift;

  @override
  State<_DedicationDialog> createState() => _DedicationDialogState();
}

class _DedicationDialogState extends State<_DedicationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: context.wp(28).clamp(20.0, 40.0)),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              dark: true,
              glow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.gift.icon,
                      style: TextStyle(fontSize: context.sp(48).clamp(36, 56))),
                  SizedBox(height: context.hp(12)),
                  Text(widget.gift.title,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: context.sp(22).clamp(18, 26),
                          fontWeight: FontWeight.w700,
                          color: _gold)),
                  SizedBox(height: context.hp(16)),
                  Text(widget.gift.dedication,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(15).clamp(13, 18),
                          height: 1.6,
                          color: _warmWhite)),
                  SizedBox(height: context.hp(24)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.wp(26).clamp(18.0, 32.0),
                          vertical: context.hp(12).clamp(10.0, 16.0)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            context.dp(16).clamp(12.0, 20.0)),
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFFB300)]),
                      ),
                      child: Text('Gracias 💛',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: context.sp(14).clamp(12, 16),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3E2723))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
