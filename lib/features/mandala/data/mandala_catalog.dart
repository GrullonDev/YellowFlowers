import 'dart:ui';

import 'mandala_color_schemes.dart';
import 'mandala_designs.dart';
import 'mandala_templates.dart';
import '../models/mandala_definition.dart';
import '../models/mandala_region.dart';

/// Emoji associated with each ring-based design.
const _designEmojis = <String, String>{
  'sol': '☀️',
  'loto': '🪷',
  'estrella': '⭐',
  'jardin': '🌿',
  'luna': '🌙',
  'corazon': '💛',
};

/// Difficulty for ring-based designs (based on region count).
const _designDifficulty = <String, int>{
  'sol': 2,
  'loto': 2,
  'estrella': 3,
  'jardin': 2,
  'luna': 3,
  'corazon': 3,
};

List<MandalaDefinition>? _cachedDefinitions;

/// Returns all available mandala definitions, combining ring-based designs
/// and legacy template-based designs into a unified format.
///
/// Results are cached after the first call.
List<MandalaDefinition> getMandalaDefinitions() {
  return _cachedDefinitions ??= [
    ..._buildFromDesigns(),
    ..._buildFromTemplates(),
  ];
}

/// Finds a definition by ID, or null if not found.
MandalaDefinition? definitionById(String id) {
  final defs = getMandalaDefinitions();
  for (final d in defs) {
    if (d.id == id) return d;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Ring-based designs → MandalaDefinition
// ---------------------------------------------------------------------------

List<MandalaDefinition> _buildFromDesigns() {
  return kMandalaDesigns.map((design) {
    final palette = kMandalaColorSchemes[design.id] ?? [];
    final paletteCount = palette.length;
    final regions = <MandalaRegion>[];
    final paths = design.regions;

    var regionIndex = 0;
    var ringIndex = 0;

    for (final ring in design.rings) {
      final colorNum = (ringIndex % paletteCount) + 1;
      final backingColorNum =
          ((ringIndex + paletteCount ~/ 2) % paletteCount) + 1;

      if (ring.kind == RingKind.center) {
        regions.add(_regionFromPath(
          design.id,
          'c',
          paths[regionIndex],
          colorNum,
          palette,
        ));
        regionIndex++;
        ringIndex++;
        continue;
      }

      if (ring.backing) {
        regions.add(_regionFromPath(
          design.id,
          'r${ringIndex}_bg',
          paths[regionIndex],
          backingColorNum,
          palette,
        ));
        regionIndex++;
      }

      for (var i = 0; i < ring.count; i++) {
        regions.add(_regionFromPath(
          design.id,
          'r${ringIndex}_$i',
          paths[regionIndex],
          colorNum,
          palette,
        ));
        regionIndex++;
      }

      ringIndex++;
    }

    return MandalaDefinition(
      id: design.id,
      name: design.name,
      emoji: _designEmojis[design.id] ?? '🎨',
      difficulty: _designDifficulty[design.id] ?? 2,
      canvasSize: kMandalaCanvas,
      regions: regions,
      palette: palette,
    );
  }).toList();
}

// ---------------------------------------------------------------------------
// Legacy template-based designs → MandalaDefinition
// ---------------------------------------------------------------------------

List<MandalaDefinition> _buildFromTemplates() {
  final templates = getBuiltInMandalas();
  return templates.map((template) {
    final palette = kMandalaColorSchemes[template.id] ?? [];
    final paletteCount = palette.length.clamp(1, 100);
    final regions = <MandalaRegion>[];

    for (var i = 0; i < template.sections.length; i++) {
      final section = template.sections[i];
      final colorNum = (i % paletteCount) + 1;
      final targetColor = palette.isNotEmpty
          ? palette[colorNum - 1].color
          : const Color(0xFFD4AF37);
      final center = _pathCenter(section.path);

      regions.add(MandalaRegion(
        id: '${template.id}_s$i',
        path: section.path,
        colorNumber: colorNum,
        targetColor: targetColor,
        center: center,
      ));
    }

    return MandalaDefinition(
      id: template.id,
      name: template.name,
      emoji: template.emoji,
      difficulty: template.difficulty,
      canvasSize: 300,
      regions: regions,
      palette: palette,
    );
  }).toList();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MandalaRegion _regionFromPath(
  String designId,
  String suffix,
  Path path,
  int colorNumber,
  List<NumberedColor> palette,
) {
  final targetColor = palette.isNotEmpty
      ? palette[(colorNumber - 1).clamp(0, palette.length - 1)].color
      : const Color(0xFFD4AF37);
  return MandalaRegion(
    id: '${designId}_$suffix',
    path: path,
    colorNumber: colorNumber,
    targetColor: targetColor,
    center: _pathCenter(path),
  );
}

/// Approximate center of a path using its bounding box center.
Offset _pathCenter(Path path) {
  final bounds = path.getBounds();
  return bounds.center;
}
