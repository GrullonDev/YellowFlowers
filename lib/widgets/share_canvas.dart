import 'package:flutter/material.dart';

/// Wraps [child] in a fixed-size canvas so a capture of this widget always
/// comes out at exactly [width]x[height] device-independent pixels. Content
/// smaller than the canvas is centered; content that would be taller or
/// wider than the canvas is scaled down to fit instead of being cropped.
class ShareCanvas extends StatelessWidget {
  const ShareCanvas({
    super.key,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.child,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: backgroundColor,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child,
          ),
        ),
      ),
    );
  }
}
