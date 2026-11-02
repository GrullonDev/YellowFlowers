import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yellow_flowers/core/design_system.dart';

/// A horizontal scrollable color palette for mandala coloring.
///
/// Displays a curated set of warm, pastel, and jewel-tone colors
/// plus an eraser option. The selected color shows a gold ring
/// and a subtle scale animation.
class ColorPalette extends StatefulWidget {
  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette>
    with TickerProviderStateMixin {
  late final List<_PaletteEntry> _entries;

  /// Track per-swatch bounce controllers keyed by index.
  final Map<int, AnimationController> _bounceControllers = {};

  static const _eraserColor = Colors.white;

  /// Curated colors: warm tones, pastels, and jewel tones that feel organic
  /// and match the app's gold/cream/lavender identity.
  static const List<_PaletteEntry> _colors = [
    _PaletteEntry(Color(0xFFD4AF37), 'Gold'),           // radiant gold
    _PaletteEntry(Color(0xFFF9E076), 'Sunflower'),      // bright sunflower
    _PaletteEntry(Color(0xFFFFAB76), 'Apricot'),        // warm apricot
    _PaletteEntry(Color(0xFFFF8A80), 'Coral'),          // soft coral
    _PaletteEntry(Color(0xFFF48FB1), 'Rose'),           // pastel rose
    _PaletteEntry(Color(0xFFCE93D8), 'Orchid'),         // soft orchid
    _PaletteEntry(Color(0xFF9FA8DA), 'Periwinkle'),     // periwinkle
    _PaletteEntry(Color(0xFF81D4FA), 'Sky'),            // sky blue
    _PaletteEntry(Color(0xFF80CBC4), 'Sage'),           // sage teal
    _PaletteEntry(Color(0xFFA5D6A7), 'Mint'),          // mint green
    _PaletteEntry(Color(0xFF2D5D3A), 'Forest'),         // leaf green (from PremiumDesign)
    _PaletteEntry(Color(0xFF8D6E63), 'Cinnamon'),       // warm brown
    _PaletteEntry(Color(0xFFBCAAA4), 'Sand'),           // warm sand
    _PaletteEntry(Color(0xFF7E57C2), 'Amethyst'),       // jewel amethyst
    _PaletteEntry(Color(0xFFE53935), 'Ruby'),           // jewel ruby
    _PaletteEntry(Color(0xFF1E88E5), 'Sapphire'),       // jewel sapphire
  ];

  @override
  void initState() {
    super.initState();
    // Build full list: eraser first, then colors.
    _entries = [
      const _PaletteEntry(_eraserColor, 'Eraser'),
      ..._colors,
    ];
  }

  @override
  void dispose() {
    for (final c in _bounceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  AnimationController _controllerFor(int index) {
    return _bounceControllers.putIfAbsent(index, () {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  void _onSelect(int index) {
    final color = _entries[index].color;
    HapticFeedback.selectionClick();

    // Trigger bounce on the tapped swatch.
    final ctrl = _controllerFor(index);
    ctrl.forward(from: 0.0);

    widget.onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) {
    final dark = PremiumDesign.isDarkMode(context);
    final bgColor = dark ? const Color(0xFF1A1530) : PremiumDesign.cream;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: PremiumDesign.s12,
        horizontal: PremiumDesign.s8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PremiumDesign.cardRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(dark ? 60 : 15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current color indicator
            Padding(
              padding: const EdgeInsets.only(bottom: PremiumDesign.s8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedLabel(),
                    style: PremiumDesign.sansLabel.copyWith(
                      color: dark
                          ? PremiumDesign.radiantGold
                          : PremiumDesign.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable swatches
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s8),
                itemCount: _entries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: PremiumDesign.s8),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isSelected = widget.selectedColor == entry.color;
                  final isEraser = index == 0;

                  return _SwatchButton(
                    color: entry.color,
                    isSelected: isSelected,
                    isEraser: isEraser,
                    bounceController: _controllerFor(index),
                    onTap: () => _onSelect(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _selectedLabel() {
    for (final entry in _entries) {
      if (entry.color == widget.selectedColor) {
        return entry.label.toUpperCase();
      }
    }
    return 'COLOR';
  }
}

class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.color,
    required this.isSelected,
    required this.isEraser,
    required this.bounceController,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final bool isEraser;
  final AnimationController bounceController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = PremiumDesign.isDarkMode(context);

    return AnimatedBuilder(
      animation: bounceController,
      builder: (context, child) {
        // Bounce: scale up then back down.
        final t = bounceController.value;
        final scale = isSelected
            ? 1.15 + 0.08 * _bounce(t)
            : 1.0 + 0.15 * _bounce(t);

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Semantics(
        button: true,
        label: isEraser ? 'Eraser' : 'Color swatch',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: PremiumDesign.fast,
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEraser
                  ? (dark ? const Color(0xFF2A2540) : Colors.white)
                  : color,
              border: isSelected
                  ? Border.all(
                      color: PremiumDesign.radiantGold,
                      width: 3.0,
                    )
                  : Border.all(
                      color: dark
                          ? Colors.white.withAlpha(30)
                          : Colors.black.withAlpha(15),
                      width: 1.0,
                    ),
              boxShadow: isSelected ? PremiumDesign.goldGlow : null,
            ),
            child: isEraser
                ? Icon(
                    Icons.auto_fix_high_rounded,
                    size: 20,
                    color: dark ? Colors.white70 : PremiumDesign.secondaryText,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// Simple bounce curve: goes up then back to zero.
  double _bounce(double t) {
    return 4.0 * t * (1.0 - t);
  }
}

class _PaletteEntry {
  const _PaletteEntry(this.color, this.label);
  final Color color;
  final String label;
}
