import 'package:flutter/material.dart';

import '../models/mandala_definition.dart';
import 'mandala_painter.dart';

/// A collapsible miniature preview showing either the completed reference
/// design or the current coloring progress.
class MandalaPreview extends StatefulWidget {
  const MandalaPreview({
    super.key,
    required this.definition,
    required this.regionColors,
  });

  final MandalaDefinition definition;
  final Map<String, Color> regionColors;

  @override
  State<MandalaPreview> createState() => _MandalaPreviewState();
}

class _MandalaPreviewState extends State<MandalaPreview> {
  bool _expanded = false;
  bool _showReference = true;

  @override
  Widget build(BuildContext context) {
    final size = _expanded ? 160.0 : 64.0;

    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: size,
          height: _expanded ? size + 32 : size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFD4AF37).withAlpha(80),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(
                      painter: MandalaPainter(
                        definition: widget.definition,
                        regionColors: _showReference
                            ? _referenceColors()
                            : widget.regionColors,
                        showNumbers: false,
                        exportMode: true,
                      ),
                      size: Size.square(size - 8),
                    ),
                  ),
                ),
                if (_expanded)
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ToggleButton(
                          label: 'Ref',
                          active: _showReference,
                          onTap: () => setState(() => _showReference = true),
                        ),
                        const SizedBox(width: 4),
                        _ToggleButton(
                          label: 'Mío',
                          active: !_showReference,
                          onTap: () => setState(() => _showReference = false),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a map of all regions → target colors for the reference view.
  Map<String, Color> _referenceColors() {
    return {
      for (final region in widget.definition.regions)
        region.id: region.targetColor,
    };
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFD4AF37).withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFFD4AF37) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
