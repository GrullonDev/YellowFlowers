import 'package:flutter/widgets.dart';

/// Rectángulo desde el que iOS presenta la hoja de compartir.
///
/// Sin `sharePositionOrigin`, `share_plus` en iOS (iPad e iPhone con iOS 26+)
/// lanza "sharePositionOrigin: argument must be set" y la hoja no aparece.
/// Calcúlalo antes de cualquier `await` para no usar el `context` tarde.
Rect shareOrigin(BuildContext context) {
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize && !box.size.isEmpty) {
    return box.localToGlobal(Offset.zero) & box.size;
  }
  final size = MediaQuery.sizeOf(context);
  return Rect.fromCenter(
      center: size.center(Offset.zero), width: 1, height: 1);
}
