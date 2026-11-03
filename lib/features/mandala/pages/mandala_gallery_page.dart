import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_catalog.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_store.dart';
import 'package:yellow_flowers/features/mandala/models/mandala_definition.dart';
import 'package:yellow_flowers/features/mandala/pages/mandala_coloring_page.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';

const _cosmicBg = Color(0xFF0B0820);
const _cosmicCard = Color(0xFF160F35);
const _cosmicCardBorder = Color(0xFF2A2255);
const _gold = Color(0xFFFFD54F);

class MandalaGalleryPage extends StatefulWidget {
  const MandalaGalleryPage({super.key});

  @override
  State<MandalaGalleryPage> createState() => _MandalaGalleryPageState();
}

class _MandalaGalleryPageState extends State<MandalaGalleryPage> {
  late final List<MandalaDefinition> _definitions;
  late final MandalaStore _store;
  final Map<String, double> _progressCache = {};

  @override
  void initState() {
    super.initState();
    _definitions = getMandalaDefinitions();
    _store = sl<MandalaStore>();
    _loadProgress();
  }

  void _loadProgress() {
    for (final def in _definitions) {
      final saved = _store.load(def.id);
      _progressCache[def.id] =
          def.regions.isEmpty ? 0.0 : saved.length / def.regions.length;
    }
  }

  void _openMandala(MandalaDefinition definition) {
    HapticFeedback.selectionClick();
    Navigator.of(context)
        .push(
      PremiumTransitions.fadeThrough(
        MandalaColoringPage(definition: definition),
      ),
    )
        .then((_) {
      if (mounted) {
        setState(() => _loadProgress());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const crossAxisCount = 2;
    const horizontalPadding = PremiumDesign.s16 * 2;
    const spacing = PremiumDesign.s16;
    final cardWidth =
        (screenWidth - horizontalPadding - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
    final childAspectRatio = cardWidth / (cardWidth + 80);

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
              tooltip: 'Volver',
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
                'Elige un mandala para colorear',
                style: PremiumDesign.sansBody.copyWith(color: Colors.white54),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final definition = _definitions[index];
                  final progress = _progressCache[definition.id] ?? 0.0;
                  return _MandalaCard(
                    definition: definition,
                    progress: progress,
                    onTap: () => _openMandala(definition),
                  );
                },
                childCount: _definitions.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: PremiumDesign.s16,
                crossAxisSpacing: PremiumDesign.s16,
                childAspectRatio: childAspectRatio,
              ),
            ),
          ),
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
    required this.definition,
    required this.progress,
    required this.onTap,
  });

  final MandalaDefinition definition;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;
    final hasProgress = progress > 0.0;

    return Semantics(
      button: true,
      label: '${definition.name}, dificultad ${definition.difficulty} de 3'
          '${isComplete ? ', completado' : hasProgress ? ', ${(progress * 100).round()}%' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _cosmicCard,
            borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
            border: Border.all(
              color: isComplete ? _gold.withAlpha(80) : _cosmicCardBorder,
              width: isComplete ? 1.5 : 1,
            ),
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
              // Mandala preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(PremiumDesign.s16),
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final previewSize = constraints.maxWidth
                              .clamp(0.0, constraints.maxHeight);
                          return Center(
                            child: SizedBox(
                              width: previewSize,
                              height: previewSize,
                              child: CustomPaint(
                                painter: MandalaPainter(
                                  definition: definition,
                                  regionColors: _referenceColors(),
                                  showNumbers: false,
                                  exportMode: true,
                                ),
                                size: Size.square(previewSize),
                              ),
                            ),
                          );
                        },
                      ),
                      if (isComplete)
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(Icons.check_circle_rounded,
                              color: _gold, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
              // Info area
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PremiumDesign.s12,
                  0,
                  PremiumDesign.s12,
                  PremiumDesign.s8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          definition.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            definition.name,
                            style: PremiumDesign.sansBody.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DifficultyStars(level: definition.difficulty),
                        if (hasProgress && !isComplete) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).round()}%',
                            style: PremiumDesign.sansLabel.copyWith(
                              color: _gold.withAlpha(180),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasProgress && !isComplete)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withAlpha(10),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_gold),
                            minHeight: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Color> _referenceColors() {
    return {
      for (final region in definition.regions) region.id: region.targetColor,
    };
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
            size: 14,
          ),
        );
      }),
    );
  }
}
