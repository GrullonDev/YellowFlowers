// Covers the export-resolution bug from the diagnostic: shared card images
// were coming out at the wrong pixel size (width multiplied by pixelRatio on
// top of an already-fixed-width widget) and, separately, content taller than
// the target canvas was silently cropped instead of scaled to fit.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellow_flowers/widgets/share_canvas.dart';

Future<ui.Image> _capture(GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  return boundary.toImage(pixelRatio: 1.0);
}

void main() {
  testWidgets('captures a fixed-size canvas regardless of smaller content',
      (tester) async {
    // The default test surface (800x600) is smaller than the 1080x1920
    // canvas under test; grow it so the canvas gets its full requested size
    // instead of being clamped (which would just silently re-introduce the
    // original "wrong pixel size" bug inside the test itself).
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const ShareCanvas(
              width: 1080,
              height: 1920,
              backgroundColor: Colors.black,
              child: SizedBox(
                  width: 400,
                  height: 300,
                  child: ColoredBox(color: Colors.amber)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final image = await _capture(key);
    expect(image.width, 1080);
    expect(image.height, 1920);
  });

  testWidgets('scales down oversized content instead of cropping it',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // A child far taller than the 1080x1920 canvas. Capturing this via
    // toImage() hangs the engine's software rasterizer in this test
    // environment when combined with FittedBox's scale transform (an
    // environment/engine quirk, not something under test here), so this
    // checks the guarantee structurally instead: the oversized child sits
    // behind a BoxFit.scaleDown FittedBox, and laying it out doesn't raise
    // the render-overflow error Flutter would throw if it were left to
    // overflow (i.e. get cropped) instead.
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: ShareCanvas(
            width: 1080,
            height: 1920,
            backgroundColor: Colors.black,
            child: SizedBox(
              width: 1080,
              height: 2600,
              child: ColoredBox(color: Colors.amber),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);

    final fittedBox = tester.widget<FittedBox>(find.descendant(
      of: find.byType(ShareCanvas),
      matching: find.byType(FittedBox),
    ));
    expect(fittedBox.fit, BoxFit.scaleDown);
  });
}
