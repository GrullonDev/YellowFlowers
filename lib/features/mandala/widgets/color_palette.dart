import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yellow_flowers/core/design_system.dart';

import '../models/mandala_definition.dart';

/// A horizontal scrollable numbered color palette for color-by-number.
///
/// Shows an eraser button followed by numbered color swatches. Each swatch
/// displays its number and optionally the remaining uncolored count.
/// The selected swatch gets a gold ring and scale animation.
class NumberedColorPalette extends StatelessWidget {
  const NumberedColorPalette({
    super.key,
    required this.palette,
    required this.selectedNumber,
    required this.onNumberSelected,
    required this.remainingCounts,
    required this.mode,
  });

  final List<NumberedColor> palette;

  /// Currently selected number, or null for eraser.
  final int? selectedNumber;
  final ValueChanged<int?> onNumberSelected;

  /// Number → remaining uncolored regions count.
  final Map<int, int> remainingCounts;
  final ColoringMode mode;

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
            // Selected color label
            Padding(
              padding: const EdgeInsets.only(bottom: PremiumDesign.s8),
              child: Text(
                _selectedLabel(),
                style: PremiumDesign.sansLabel.copyWith(
                  color: dark
                      ? PremiumDesign.radiantGold
                      : PremiumDesign.secondaryText,
                ),
              ),
            ),
            // Scrollable swatches
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s8),
                itemCount: palette.length + 1, // +1 for eraser
                separatorBuilder: (_, __) =>
                    const SizedBox(width: PremiumDesign.s8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _EraserSwatch(
                      isSelected: selectedNumber == null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onNumberSelected(null);
                      },
                    );
                  }
                  final entry = palette[index - 1];
                  final remaining = remainingCounts[entry.number] ?? 0;
                  final isSelected = selectedNumber == entry.number;
                  final isDone = remaining == 0;

                  return _NumberedSwatch(
                    number: entry.number,
                    color: entry.color,
                    isSelected: isSelected,
                    isDone: isDone,
                    remaining: mode == ColoringMode.guided ? remaining : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onNumberSelected(entry.number);
                    },
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
    if (selectedNumber == null) return 'BORRADOR';
    for (final entry in palette) {
      if (entry.number == selectedNumber) {
        return entry.name.toUpperCase();
      }
    }
    return 'COLOR';
  }
}

class _NumberedSwatch extends StatelessWidget {
  const _NumberedSwatch({
    required this.number,
    required this.color,
    required this.isSelected,
    required this.isDone,
    required this.remaining,
    required this.onTap,
  });

  final int number;
  final Color color;
  final bool isSelected;
  final bool isDone;
  final int? remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Color $number${isDone ? ', completado' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: PremiumDesign.fast,
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: 48,
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: PremiumDesign.fast,
                  curve: Curves.easeOutCubic,
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isSelected
                        ? Border.all(
                            color: PremiumDesign.radiantGold, width: 3.0)
                        : Border.all(
                            color: Colors.black.withAlpha(20), width: 1.0),
                    boxShadow: isSelected ? PremiumDesign.goldGlow : null,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 18, color: Colors.white)
                        : Text(
                            '$number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _contrastColor(color),
                            ),
                          ),
                  ),
                ),
                if (remaining != null && !isDone)
                  Text(
                    '$remaining',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF333333) : Colors.white;
  }
}

class _EraserSwatch extends StatelessWidget {
  const _EraserSwatch({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = PremiumDesign.isDarkMode(context);
    return Semantics(
      button: true,
      label: 'Borrador',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: PremiumDesign.fast,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: PremiumDesign.fast,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? const Color(0xFF2A2540) : Colors.white,
              border: isSelected
                  ? Border.all(color: PremiumDesign.radiantGold, width: 3.0)
                  : Border.all(
                      color: dark
                          ? Colors.white.withAlpha(30)
                          : Colors.black.withAlpha(15),
                      width: 1.0),
              boxShadow: isSelected ? PremiumDesign.goldGlow : null,
            ),
            child: Icon(
              Icons.auto_fix_high_rounded,
              size: 20,
              color: dark ? Colors.white70 : PremiumDesign.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
