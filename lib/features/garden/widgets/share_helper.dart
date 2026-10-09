import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/share_origin.dart';
import 'package:yellow_flowers/utils/constants.dart';
import 'package:yellow_flowers/widgets/share_canvas.dart';

Future<void> captureAndShare(
  BuildContext context, {
  required Widget card,
  required String shareText,
}) async {
  final origin = shareOrigin(context);
  final shareKey = GlobalKey();
  final overlay = OverlayEntry(
    builder: (_) => Positioned(
      left: -4000,
      top: -4000,
      child: Opacity(
        opacity: 0.01,
        child: RepaintBoundary(
          key: shareKey,
          child: Material(
            color: Colors.transparent,
            child: ShareCanvas(
              width: kShareImageWidth,
              height: kShareImageHeight,
              backgroundColor: kShareCanvasBackground,
              child: card,
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlay);

  await Future.delayed(const Duration(milliseconds: 300));
  await WidgetsBinding.instance.endOfFrame;

  try {
    final boundary =
        shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // The boundary is already sized at the exact target pixel dimensions
    // (kShareImageWidth x kShareImageHeight), so pixelRatio stays at 1.0 —
    // multiplying it further was the cause of the oversized export bug.
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = await File(
            '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png')
        .create();
    await file.writeAsBytes(pngBytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      text: shareText,
      sharePositionOrigin: origin,
    ));
  } catch (e) {
    debugPrint('Share error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No pudimos compartir la imagen. Intenta de nuevo.')),
      );
    }
  } finally {
    overlay.remove();
  }
}
