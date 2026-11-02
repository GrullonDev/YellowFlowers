import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_templates.dart';
import 'package:yellow_flowers/features/mandala/models/mandala_template.dart';
import 'package:yellow_flowers/features/mandala/pages/mandala_coloring_page.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart'
    show MandalaPainter;

/// The dark cosmic background used consistently across the garden area.
const _cosmicBg = Color(0xFF0B0820);

/// Lighter cosmic tone for card surfaces.
const _cosmicCard = Color(0xFF160F35);
const _cosmicCardBorder = Color(0xFF2A2255);
const _gold = Color(0xFFFFD54F);

/// A gallery page that displays available mandala templates in a 2-column grid.
///
/// Each card shows a small preview of the mandala rendered via [MandalaPainter],
/// the template name, emoji, and difficulty stars. Tapping a card navigates
/// to [MandalaColoringPage].
class MandalaGalleryPage extends StatelessWidget {
  const MandalaGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mandalas = getBuiltInMandalas();
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Two-column grid: account for padding and spacing.
    const crossAxisCount = 2;
    const horizontalPadding = PremiumDesign.s16 * 2;
    const spacing = PremiumDesign.s16;
    final cardWidth =
        (screenWidth - horizontalPadding - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
    // Keep cards roughly square plus room for the label area.
    final childAspectRatio = cardWidth / (cardWidth + 72);

    return Scaffold(
      backgroundColor: _cosmicBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: _cosmicBg,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: _gold),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mandalas',
                style: PremiumDesign.serifHeading.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 56, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumDesign.s16,
              vertical: PremiumDesign.s12,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Choose a mandala to color',
                style: PremiumDesign.sansBody.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final template = mandalas[index];
                  return _MandalaCard(
                    template: template,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        PremiumTransitions.fadeThrough(
                          MandalaColoringPage(template: template),
                        ),
                      );
                    },
                  );
                },
                childCount: mandalas.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: PremiumDesign.s16,
                crossAxisSpacing: PremiumDesign.s16,
                childAspectRatio: childAspectRatio,
              ),
            ),
          ),
          // Bottom safe-area spacer.
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + PremiumDesign.s32,
            ),
          ),
        ],
      ),
    );
  }
}

class _MandalaCard extends StatelessWidget {
  const _MandalaCard({
    required this.template,
    required this.onTap,
  });

  final MandalaTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${template.name} mandala, difficulty ${template.difficulty} of 3',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _cosmicCard,
            borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
            border: Border.all(color: _cosmicCardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mandala preview area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(PremiumDesign.s16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final previewSize =
                          constraints.maxWidth.clamp(0.0, constraints.maxHeight);
                      return Center(
                        child: SizedBox(
                          width: previewSize,
                          height: previewSize,
                          child: CustomPaint(
                            painter: MandalaPainter(
                              template: template,
                            ),
                            size: Size.square(previewSize),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Info area
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PremiumDesign.s12,
                  0,
                  PremiumDesign.s12,
                  PremiumDesign.s12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          template.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            template.name,
                            style: PremiumDesign.sansBody.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _DifficultyStars(level: template.difficulty),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < level;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? _gold : Colors.white24,
            size: 16,
          ),
        );
      }),
    );
  }
}
