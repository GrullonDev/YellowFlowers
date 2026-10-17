import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/share_origin.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_designs.dart';
import 'package:yellow_flowers/features/mandala/data/mandala_store.dart';
import 'package:yellow_flowers/features/mandala/widgets/mandala_painter.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

/// Colores suaves primero (los que más calman), luego tonos vivos.
const _palette = <Color>[
  Color(0xFFFFE082),
  Color(0xFFFFCC80),
  Color(0xFFFFAB91),
  Color(0xFFF8BBD0),
  Color(0xFFE1BEE7),
  Color(0xFFD1C4E9),
  Color(0xFFBBDEFB),
  Color(0xFFB2EBF2),
  Color(0xFFC8E6C9),
  Color(0xFFF0F4C3),
  Color(0xFFFFD54F),
  Color(0xFFFFA726),
  Color(0xFFFF7043),
  Color(0xFFEC407A),
  Color(0xFFAB47BC),
  Color(0xFF7E57C2),
  Color(0xFF42A5F5),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFF8D6E63),
];

/// Lienzo para colorear un mandala tocando cada zona.
class MandalaColoringPage extends StatefulWidget {
  const MandalaColoringPage({super.key, required this.design});
  final MandalaDesign design;

  @override
  State<MandalaColoringPage> createState() => _MandalaColoringPageState();
}

class _MandalaColoringPageState extends State<MandalaColoringPage> {
  final _store = MandalaStore(sl<SharedPreferences>());
  final _boundaryKey = GlobalKey();
  late final Map<int, Color> _colors = _store.load(widget.design.id);

  /// Pila para deshacer: (zona, color anterior o null si estaba en blanco).
  final _history = <(int, Color?)>[];
  Color _selected = _palette.first;
  bool _eraser = false;
  int _version = 0;
  bool _celebrated = false;

  int get _total => widget.design.regions.length;

  @override
  void initState() {
    super.initState();
    _celebrated = _colors.length >= _total;
  }

  void _tapAt(Offset local, double side) {
    final region = hitMandalaRegion(widget.design, local, side);
    if (region == null) return;
    final previous = _colors[region];
    final next = _eraser ? null : _selected;
    if (previous == next) return;

    HapticFeedback.selectionClick();
    setState(() {
      _history.add((region, previous));
      if (next == null) {
        _colors.remove(region);
      } else {
        _colors[region] = next;
      }
      _version++;
    });
    _store.save(widget.design.id, _colors);
    _maybeCelebrate();
  }

  void _maybeCelebrate() {
    if (_celebrated || _colors.length < _total) return;
    _celebrated = true;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2A1A3A),
      content: Text('¡Terminaste tu mandala! Así de bonito es lo que creas 🌸',
          style: GoogleFonts.plusJakartaSans(
              color: _warmWhite, fontWeight: FontWeight.w700)),
    ));
  }

  void _undo() {
    if (_history.isEmpty) return;
    final (region, previous) = _history.removeLast();
    setState(() {
      if (previous == null) {
        _colors.remove(region);
      } else {
        _colors[region] = previous;
      }
      _version++;
    });
    _store.save(widget.design.id, _colors);
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1030),
        title: Text('¿Empezar de nuevo?',
            style: GoogleFonts.playfairDisplay(color: _warmWhite)),
        content: Text('Se borrarán los colores de este mandala.',
            style:
                GoogleFonts.plusJakartaSans(color: _warmWhite.withAlpha(180))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _colors.clear();
      _history.clear();
      _celebrated = false;
      _version++;
    });
    _store.clear(widget.design.id);
  }

  Future<void> _share(BuildContext buttonContext) async {
    final origin = shareOrigin(buttonContext);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/mandala_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Coloreé este mandala en Amarillas 🌻',
        sharePositionOrigin: origin,
      ));
    } catch (e) {
      debugPrint('Mandala share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _colors.length / _total;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _warmWhite,
        title: Text(widget.design.name,
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, color: _warmWhite)),
        actions: [
          IconButton(
            tooltip: 'Deshacer',
            onPressed: _history.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'Empezar de nuevo',
            onPressed: _colors.isEmpty ? null : _clear,
            icon: const Icon(Icons.refresh_rounded),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: 'Compartir',
              onPressed: () => _share(buttonContext),
              icon: const Icon(Icons.ios_share_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
                color: _gold,
                backgroundColor: _warmWhite.withAlpha(25),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 6,
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          final side = constraints.biggest.shortestSide;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (d) => _tapAt(d.localPosition, side),
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: CustomPaint(
                                size: Size.square(side),
                                painter: MandalaPainter(widget.design, _colors,
                                    version: _version),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text('Pellizca para acercar · toca una zona para pintarla',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: _warmWhite.withAlpha(120))),
            const SizedBox(height: 10),
            _PaletteBar(
              selected: _selected,
              eraser: _eraser,
              onColor: (c) => setState(() {
                _selected = c;
                _eraser = false;
              }),
              onEraser: () => setState(() => _eraser = !_eraser),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PaletteBar extends StatelessWidget {
  const _PaletteBar({
    required this.selected,
    required this.eraser,
    required this.onColor,
    required this.onEraser,
  });
  final Color selected;
  final bool eraser;
  final ValueChanged<Color> onColor;
  final VoidCallback onEraser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Swatch(
            color: kMandalaPaper,
            selected: eraser,
            onTap: onEraser,
            child: const Icon(Icons.auto_fix_normal_rounded,
                color: kMandalaInk, size: 22),
          ),
          for (final c in _palette)
            _Swatch(
              color: c,
              selected: !eraser && c == selected,
              onTap: () => onColor(c),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.child,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: selected ? 48 : 40,
        height: selected ? 48 : 40,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
              color: selected ? _gold : _warmWhite.withAlpha(60),
              width: selected ? 3 : 1),
          boxShadow: selected
              ? [BoxShadow(color: color.withAlpha(120), blurRadius: 12)]
              : null,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
