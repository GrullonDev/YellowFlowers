import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/utils/styles/button_style.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    this.title,
    this.child,
    required this.onTap,
    this.margin = EdgeInsets.zero,
    this.style,
  }) : assert(title != null || child != null);

  final String? title;
  final VoidCallback? onTap;

  /// When child is not null it will be displayed
  final Widget? child;
  final EdgeInsetsGeometry margin;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: margin,
      child: ElevatedButton(
        style: style ?? UIButtonStyle.elevatedButtonStyle(),
        onPressed: onTap,
        child: child ??
            FittedBox(
              child: Text(title!),
            ),
      ),
    );
  }
}
