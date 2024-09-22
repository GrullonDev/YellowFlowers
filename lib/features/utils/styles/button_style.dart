import 'package:flutter/material.dart';

class UIButtonStyle {
  UIButtonStyle._();

  static ButtonStyle elevatedButtonStyle({
    Color onPrimary = Colors.white,
    Color primary = Colors.blueAccent,
    Color? onSurface,
    Size size = _minSize,
    EdgeInsets padding = baseButtonPadding,
    double radius = 15,
    double? elevation,
    TextStyle? textStyle,
  }) {
    return ElevatedButton.styleFrom(
      foregroundColor: onPrimary,
      backgroundColor: primary,
      disabledForegroundColor: onSurface,
      minimumSize: size,
      maximumSize: size,
      padding: padding,
      elevation: elevation,
      shape: baseButtonRadius(radius),
      textStyle: textStyle,
    );
  }

  static ButtonStyle textButtonStyle({
    Color primary = Colors.blueAccent,
    Size size = _minSize,
    EdgeInsets padding = baseButtonPadding,
    double radius = 15,
    bool isGlobalStyle = false,
    TextStyle? textStyle,
  }) {
    if (isGlobalStyle) {
      return TextButton.styleFrom(foregroundColor: primary);
    }

    return TextButton.styleFrom(
      foregroundColor: primary,
      minimumSize: size,
      maximumSize: size,
      padding: padding,
      shape: baseButtonRadius(radius),
      textStyle: textStyle,
    );
  }

  static ButtonStyle outlinedButtonStyle({
    Color primary = Colors.blueAccent,
    Color? borderColor = Colors.indigoAccent,
    Size size = _minSize,
    EdgeInsets padding = baseButtonPadding,
    double radius = 15,
    TextStyle? textStyle,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: BorderSide(
        width: 1,
        color: borderColor ?? Colors.grey[400]!,
      ),
      minimumSize: size,
      maximumSize: size,
      padding: padding,
      shape: baseButtonRadius(radius),
      textStyle: textStyle,
    );
  }

  static OutlinedBorder baseButtonRadius(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(radius),
      ),
    );
  }

  static const baseButtonPadding = EdgeInsets.fromLTRB(14, 8, 10, 8);
  static const _minSize = Size(250, 40);
}
