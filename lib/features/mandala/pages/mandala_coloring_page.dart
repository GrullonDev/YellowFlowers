import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/share_origin.dart';
import 'package:yellow_flowers/features/mandala/models/mandala_template.dart';
import 'package:yellow_flowers/features/mandala/widgets/color_palette.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';

/// The dark cosmic background used consistently across the garden area.
const _cosmicBg = Color(0xFF0B0820);
const _gold = Color(0xFFFFD54F);

/// Main coloring page for a mandala.
///
/// Features:
/// - Large interactive canvas that fills the available width
/// - Tap-to-color with hit-testing via [hitTestMandala]
/// - Undo stack for reverting individual section changes
/// - Progress indicator (sections colored / total)
/// - Reset with confirmation dialog
/// - Share the finished mandala as an image
class MandalaColoringPage extends StatefulWidget {
  const MandalaColoringPage({super.key, required this.template});

  final MandalaTemplate template;

  @override
  State<MandalaColoringPage> createState() => _MandalaColoringPageState();
}

class _MandalaColoringPageState extends State<MandalaColoringPage>
    with TickerProviderStateMixin {
  /// Currently selected paint color.
  Color _selectedColor = const Color(0xFFD4AF37); // default gold

  /// Undo stack: each entry is (sectionIndex, previousColor).
  final List<_UndoEntry> _undoStack = [];

  /// Key for RepaintBoundary around the mandala canvas.
  final GlobalKey _canvasBoundaryKey = GlobalKey();

  /// Controls whether we're sharing (to show a loading indicator).
  bool _sharing = false;

  /// Animation controller for the "flash" when a section is painted.
  late final AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Coloring logic
  // ---------------------------------------------------------------------------

  int get _coloredCount {
    return widget.template.sections
        .where((s) => s.color != Colors.white)
        .length;
  }

  int get _totalSections => widget.template.sections.length;

  void _onTapCanvas(Offset localPosition, double canvasSize) {
    final index = _hitTestSection(localPosition, canvasSize);
    if (index < 0) return;

    final section = widget.template.sections[index];
    final previousColor = section.color;

    // Don't record a no-op.
    if (previousColor == _selectedColor) return;

    _undoStack.add(_UndoEntry(index, previousColor));
    section.color = _selectedColor;

    HapticFeedback.lightImpact();
    _flashController.forward(from: 0.0);

    setState(() {});
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final entry = _undoStack.removeLast();
    widget.template.sections[entry.sectionIndex].color = entry.previousColor;
    HapticFeedback.selectionClick();
    setState(() {});
  }

  /// Hit-test the mandala sections at [localPosition] within a square canvas
  /// of [canvasSize]. Returns the section index or -1 if nothing was tapped.
  ///
  /// Mandala paths live in a 300x300 coordinate space centered at the origin.
  int _hitTestSection(Offset localPosition, double canvasSize) {
    final double scale = canvasSize / 300.0;
    final Offset mandalaPoint = Offset(
      (localPosition.dx - canvasSize / 2) / scale,
      (localPosition.dy - canvasSize / 2) / scale,
    );
    final sections = widget.template.sections;
    for (int i = sections.length - 1; i >= 0; i--) {
      if (sections[i].path.contains(mandalaPoint)) return i;
    }
    return -1;
  }

  Future<void> _resetWithConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1530),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
        ),
        title: Text(
          'Reset mandala?',
          style: PremiumDesign.serifSubHeading.copyWith(color: Colors.white),
        ),
        content: Text(
          'This will clear all colors and cannot be undone.',
          style: PremiumDesign.sansBody.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: PremiumDesign.sansBody.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Reset',
              style:
                  PremiumDesign.sansBody.copyWith(color: PremiumDesign.radiantGold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final section in widget.template.sections) {
        section.color = Colors.white;
      }
      _undoStack.clear();
      HapticFeedback.mediumImpact();
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Share
  // ---------------------------------------------------------------------------

  Future<void> _shareMandala() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    // Capture origin before any async gap.
    final origin = shareOrigin(context);

    try {
      final boundary = _canvasBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas boundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File(
        '${dir.path}/mandala_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'My ${widget.template.name} mandala ${widget.template.emoji}',
        sharePositionOrigin: origin,
      ));
    } catch (e) {
      debugPrint('Mandala share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not share the mandala. Please try again.',
              style: PremiumDesign.sansBody.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2A2255),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final canvasSize = screenWidth - PremiumDesign.s32; // 16px padding each side
    final progress = _totalSections > 0 ? _coloredCount / _totalSections : 0.0;

    return Scaffold(
      backgroundColor: _cosmicBg,
      appBar: AppBar(
        backgroundColor: _cosmicBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _gold),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.template.emoji} ${widget.template.name}',
          style: PremiumDesign.serifSubHeading.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Undo button
          IconButton(
            icon: Icon(
              Icons.undo_rounded,
              color: _undoStack.isNotEmpty ? _gold : Colors.white24,
            ),
            tooltip: 'Undo',
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white54),
            tooltip: 'Reset',
            onPressed: _resetWithConfirmation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _ProgressBar(
            colored: _coloredCount,
            total: _totalSections,
            progress: progress,
          ),

          // Mandala canvas (expanded to fill space between progress and palette)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(PremiumDesign.s16),
                child: RepaintBoundary(
                  key: _canvasBoundaryKey,
                  child: Container(
                    width: canvasSize,
                    height: canvasSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(PremiumDesign.cardRadius / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(PremiumDesign.cardRadius / 2),
                      child: GestureDetector(
                        onTapDown: (details) {
                          _onTapCanvas(details.localPosition, canvasSize);
                        },
                        child: AnimatedBuilder(
                          animation: _flashController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: MandalaPainter(
                                template: widget.template,
                              ),
                              size: Size.square(canvasSize),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Share button row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s16),
            child: _ShareButton(
              onTap: _shareMandala,
              sharing: _sharing,
            ),
          ),

          // Color palette
          ColorPalette(
            selectedColor: _selectedColor,
            onColorSelected: (color) {
              setState(() => _selectedColor = color);
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Supporting widgets
// -----------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.colored,
    required this.total,
    required this.progress,
  });

  final int colored;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumDesign.s24,
        vertical: PremiumDesign.s8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$colored of $total',
                style: PremiumDesign.sansLabel.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: PremiumDesign.sansLabel.copyWith(
                  color: _gold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: PremiumDesign.fast,
              curve: Curves.easeOutCubic,
              height: 4,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(15),
                valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap, required this.sharing});

  final VoidCallback onTap;
  final bool sharing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PremiumDesign.s8),
      child: Semantics(
        button: true,
        label: 'Share mandala',
        child: GestureDetector(
          onTap: sharing ? null : onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF9E076)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: PremiumDesign.goldGlow,
            ),
            child: Center(
              child: sharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.share_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'SHARE',
                          style: PremiumDesign.sansLabel.copyWith(
                            color: Colors.white,
                            letterSpacing: 2.0,
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

class _UndoEntry {
  const _UndoEntry(this.sectionIndex, this.previousColor);
  final int sectionIndex;
  final Color previousColor;
}
