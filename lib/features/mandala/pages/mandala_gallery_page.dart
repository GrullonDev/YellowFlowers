import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/responsive.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_designs.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_store.dart';
import 'package:yellow_flowers/features/mandala/pages/mandala_coloring_page.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';
import 'package:yellow_flowers/widgets/luminous_background.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

/// Lista de mandalas para colorear, con el avance de cada uno.
class MandalaGalleryPage extends StatefulWidget {
  const MandalaGalleryPage({super.key});

  @override
  State<MandalaGalleryPage> createState() => _MandalaGalleryPageState();
}

class _MandalaGalleryPageState extends State<MandalaGalleryPage> {
  final _store = MandalaStore(sl<SharedPreferences>());

  Future<void> _open(MandalaDesign design) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MandalaColoringPage(design: design)));
    if (mounted) setState(() {}); // refresca miniaturas y avance
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.wp(16).clamp(12.0, 24.0);
    final cols = context.gridColumns(small: 2, medium: 3, large: 4);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _warmWhite,
        title: Text('Mandalas',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, color: _warmWhite)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: LuminousBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Colorear despacio calma la mente. Elige uno y pinta '
                      'a tu ritmo: tus colores se guardan solos.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(13).clamp(11, 15),
                          height: 1.4,
                          color: _warmWhite.withAlpha(170)),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                  sliver: SliverGrid.count(
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                    children: [
                      for (final design in kMandalaDesigns)
                        _MandalaTile(
                          design: design,
                          colors: _store.load(design.id),
                          onTap: () => _open(design),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MandalaTile extends StatelessWidget {
  const _MandalaTile(
      {required this.design, required this.colors, required this.onTap});
  final MandalaDesign design;
  final Map<int, Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = colors.length / design.regions.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withAlpha(16),
          border: Border.all(color: _gold.withAlpha(40)),
        ),
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(painter: MandalaPainter(design, colors)),
              ),
            ),
            const SizedBox(height: 10),
            Text(design.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _warmWhite)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
              color: _gold,
              backgroundColor: _warmWhite.withAlpha(25),
            ),
            const SizedBox(height: 4),
            Text(
                progress == 0
                    ? 'Sin empezar'
                    : progress >= 1
                        ? 'Terminado ✨'
                        : '${(progress * 100).round()}% coloreado',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: _warmWhite.withAlpha(140))),
          ],
        ),
      ),
    );
  }
}
