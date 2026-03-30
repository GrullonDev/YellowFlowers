import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';

class MusicListTile extends StatelessWidget {
  const MusicListTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    this.isSelected = false,
  });

  final Song song;
  final bool isPlaying;
  final bool isSelected;
  final VoidCallback onTap;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        isSelected ? const Color(0xFFE91E8C) : PremiumDesign.secondaryText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFFE4EC).withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFE91E8C).withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFFE91E8C).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: const Color(0xFFE91E8C).withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // ── Album cover + playing overlay ──────────────────────────
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: song.coverUrl.isNotEmpty
                          ? Image.network(
                              song.coverUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _coverPlaceholder(),
                            )
                          : _coverPlaceholder(),
                    ),
                    if (isPlaying)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.38),
                            child: const Center(
                              child: _WaveformIndicator(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Song info ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PremiumDesign.softText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: PremiumDesign.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Genre pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            song.genre,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Duration
                        Text(
                          _fmt(song.duration),
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Play / pause icon ───────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE91E8C).withValues(alpha: 0.12)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: accent,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF8BBD0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.music_note_rounded,
            color: Color(0xFFE91E8C), size: 24),
      );
}

// ─── Animated waveform bars (shown over album art while playing) ───────────────

class _WaveformIndicator extends StatefulWidget {
  const _WaveformIndicator();

  @override
  State<_WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<_WaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 18,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(painter: _BarsPainter(_ctrl.value));
        },
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 4;
    final barW = size.width / (barCount * 2 - 1);
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barW;

    for (int i = 0; i < barCount; i++) {
      final phase = i * 0.6;
      final h = 0.25 +
          0.75 * math.sin((t * 2 * math.pi) + phase).abs();
      final barH = size.height * h;
      final x = i * barW * 2 + barW / 2;
      canvas.drawLine(
        Offset(x, (size.height - barH) / 2),
        Offset(x, (size.height + barH) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.t != t;
}
