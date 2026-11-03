import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/share_origin.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/mandala/controllers/mandala_coloring_controller.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_store.dart';
import 'package:yellow_flowers/features/mandala/models/mandala_definition.dart';
import 'package:yellow_flowers/features/mandala/widgets/color_palette.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_preview.dart';

const _cosmicBg = Color(0xFF0B0820);
const _gold = Color(0xFFFFD54F);

class MandalaColoringPage extends StatefulWidget {
  const MandalaColoringPage({super.key, required this.definition});

  final MandalaDefinition definition;

  @override
  State<MandalaColoringPage> createState() => _MandalaColoringPageState();
}

class _MandalaColoringPageState extends State<MandalaColoringPage>
    with TickerProviderStateMixin {
  late final MandalaColoringController _controller;
  late final TransformationController _transformController;
  late final AnimationController _highlightAnim;
  late final AnimationController _completionAnim;

  bool _sharing = false;
  bool _isScaling = false;

  static const _minScale = 1.0;
  static const _maxScale = 5.0;

  @override
  void initState() {
    super.initState();
    _controller = MandalaColoringController(
      definition: widget.definition,
      store: sl<MandalaStore>(),
    );
    _controller.addListener(_onControllerChanged);

    _transformController = TransformationController();

    _highlightAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _completionAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _transformController.dispose();
    _highlightAnim.dispose();
    _completionAnim.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.isComplete &&
        _completionAnim.status != AnimationStatus.completed) {
      _completionAnim.forward();
    }
    setState(() {});
  }

  // ── Zoom ───────────────────────────────────────────────────────────────

  void _resetView() {
    _transformController.value = Matrix4.identity();
    HapticFeedback.lightImpact();
  }

  void _handleDoubleTap() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale > 1.5) {
      _resetView();
    } else {
      _transformController.value = Matrix4.diagonal3Values(3.0, 3.0, 1.0);
    }
    HapticFeedback.lightImpact();
  }

  // ── Canvas tap ─────────────────────────────────────────────────────────

  void _onCanvasTapUp(TapUpDetails details, Size canvasSize) {
    if (_isScaling) return;

    // The GestureDetector is inside InteractiveViewer, so localPosition
    // is already in the child's (untransformed) coordinate space.
    final regionId = hitTestMandalaRegion(
      widget.definition,
      details.localPosition,
      canvasSize,
    );
    if (regionId == null) return;
    _controller.colorRegion(regionId);
  }

  // ── Export / share ─────────────────────────────────────────────────────

  Future<void> _shareMandala() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    final origin = shareOrigin(context);

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const exportSize = Size(2048, 2048);

      // White background
      canvas.drawRect(
        Offset.zero & exportSize,
        Paint()..color = Colors.white,
      );

      MandalaPainter(
        definition: widget.definition,
        regionColors: Map.of(_controller.coloredRegions),
        exportMode: true,
        showNumbers: false,
      ).paint(canvas, exportSize);

      final picture = recorder.endRecording();
      final image = await picture.toImage(2048, 2048);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to encode image');

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File(
        '${dir.path}/mandala_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Mi mandala ${widget.definition.name} ${widget.definition.emoji}',
        sharePositionOrigin: origin,
      ));
    } catch (e) {
      debugPrint('Mandala share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo compartir el mandala. Intenta de nuevo.',
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

  // ── Reset ──────────────────────────────────────────────────────────────

  Future<void> _resetWithConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1530),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
        ),
        title: Text(
          '¿Reiniciar mandala?',
          style: PremiumDesign.serifSubHeading.copyWith(color: Colors.white),
        ),
        content: Text(
          'Se borrarán todos los colores y no se puede deshacer.',
          style: PremiumDesign.sansBody.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: PremiumDesign.sansBody.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Reiniciar',
              style: PremiumDesign.sansBody
                  .copyWith(color: PremiumDesign.radiantGold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.reset();
      _completionAnim.reset();
      _resetView();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final canvasSize = screenWidth - PremiumDesign.s32;

    final remainingCounts = <int, int>{};
    for (final entry in widget.definition.palette) {
      remainingCounts[entry.number] =
          _controller.remainingForNumber(entry.number);
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _controller.flushSave();
      },
      child: Scaffold(
        backgroundColor: _cosmicBg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _ProgressBar(
              colored: _controller.coloredCount,
              total: _controller.totalRegions,
              progress: _controller.progress,
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildCanvas(canvasSize),
                  MandalaPreview(
                    definition: widget.definition,
                    regionColors: Map.of(_controller.coloredRegions),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _ZoomButton(
                      icon: Icons.center_focus_strong_rounded,
                      tooltip: 'Restablecer vista',
                      onTap: _resetView,
                    ),
                  ),
                  if (_controller.isComplete)
                    _CompletionOverlay(animation: _completionAnim),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: PremiumDesign.s16),
              child: _ShareButton(
                onTap: _shareMandala,
                sharing: _sharing,
              ),
            ),
            NumberedColorPalette(
              palette: widget.definition.palette,
              selectedNumber: _controller.selectedNumber,
              onNumberSelected: _controller.selectNumber,
              remainingCounts: remainingCounts,
              mode: _controller.mode,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _cosmicBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: _gold),
        tooltip: 'Volver',
        onPressed: () {
          _controller.flushSave();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        '${widget.definition.emoji} ${widget.definition.name}',
        style: PremiumDesign.serifSubHeading.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.undo_rounded,
            color: _controller.canUndo ? _gold : Colors.white24,
          ),
          tooltip: 'Deshacer',
          onPressed: _controller.canUndo ? _controller.undo : null,
        ),
        IconButton(
          icon: Icon(
            Icons.redo_rounded,
            color: _controller.canRedo ? _gold : Colors.white24,
          ),
          tooltip: 'Rehacer',
          onPressed: _controller.canRedo ? _controller.redo : null,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
          color: const Color(0xFF1A1530),
          onSelected: (value) {
            switch (value) {
              case 'reset':
                _resetWithConfirmation();
              case 'mode':
                _controller.switchMode(
                  _controller.mode == ColoringMode.guided
                      ? ColoringMode.free
                      : ColoringMode.guided,
                );
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'mode',
              child: Text(
                _controller.mode == ColoringMode.guided
                    ? 'Modo libre'
                    : 'Modo guiado',
                style: PremiumDesign.sansBody.copyWith(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'reset',
              child: Text(
                'Reiniciar',
                style: PremiumDesign.sansBody.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCanvas(double canvasSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PremiumDesign.s16),
        child: Container(
          width: canvasSize,
          height: canvasSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PremiumDesign.cardRadius / 2),
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: _minScale,
                maxScale: _maxScale,
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                onInteractionStart: (details) {
                  if (details.pointerCount >= 2) _isScaling = true;
                },
                onInteractionEnd: (_) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted) _isScaling = false;
                  });
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) =>
                      _onCanvasTapUp(details, Size.square(canvasSize)),
                  child: AnimatedBuilder(
                    animation: _highlightAnim,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: MandalaPainter(
                          definition: widget.definition,
                          regionColors: Map.of(_controller.coloredRegions),
                          highlightNumber: _controller.selectedNumber,
                          highlightPhase: _highlightAnim.value,
                          showNumbers: true,
                          mode: _controller.mode,
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
    );
  }
}

// ── Supporting widgets ───────────────────────────────────────────────────────

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
                '$colored de $total',
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
        label: 'Compartir mandala',
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
                          'COMPARTIR',
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

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF4E342E)),
        ),
      ),
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({required this.animation});

  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final opacity = Curves.easeInOut.transform(
          (animation.value * 2).clamp(0.0, 1.0),
        );
        final scale = 0.5 +
            0.5 *
                Curves.elasticOut.transform(
                  ((animation.value - 0.2) * 1.25).clamp(0.0, 1.0),
                );
        if (opacity < 0.01) return const SizedBox.shrink();

        return Center(
          child: Opacity(
            opacity: opacity * 0.9,
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1530).withAlpha(230),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: PremiumDesign.goldGlow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(
                      '¡Completado!',
                      style: PremiumDesign.serifSubHeading.copyWith(
                        color: _gold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
