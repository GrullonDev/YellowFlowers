import 'dart:math' as math;
import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  static const _designWidth = 375.0;
  static const _designHeight = 812.0;

  Size get _size => MediaQuery.of(this).size;
  double get _sw => (_size.width / _designWidth).clamp(0.75, 1.3);
  double get _sh => (_size.height / _designHeight).clamp(0.75, 1.3);
  double get _textScale => MediaQuery.of(this).textScaler.scale(1);

  bool get isMobile => _size.width < 600;
  bool get isTablet => _size.width >= 600 && _size.width < 900;
  bool get isDesktop => _size.width >= 900;

  bool get isSmallPhone => _size.width < 360;
  bool get isLargePhone => _size.width >= 400 && _size.width < 600;

  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  /// Scale font size proportionally, compensating for system text scale.
  double sp(double size) => (size * _sw / _textScale).roundToDouble();

  /// Scale horizontal dimension proportionally.
  double wp(double size) => size * _sw;

  /// Scale vertical dimension proportionally.
  double hp(double size) => size * _sh;

  /// Scale uniformly (min of horizontal/vertical factor).
  double dp(double size) => size * math.min(_sw, _sh);

  /// Symmetric horizontal padding, scaled.
  EdgeInsets padH(double h) => EdgeInsets.symmetric(horizontal: wp(h));

  /// Adaptive grid columns based on screen width.
  int gridColumns({int small = 2, int medium = 3, int large = 4}) {
    if (isSmallPhone) return small;
    if (isLargePhone || isTablet) return large;
    return medium;
  }

  /// Clearance for the floating glassmorphism bottom nav bar.
  double get bottomNavClearance {
    final bottom = MediaQuery.of(this).padding.bottom;
    return hp(64) + bottom + hp(16);
  }
}
