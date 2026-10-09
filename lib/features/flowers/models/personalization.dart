enum FlowerTheme {
  sunflower,
  rose,
  daisy,
}

enum Mood {
  joy,
  calm,
  passion,
}

/// Animation style for background flowers.
enum FlowerAnimationStyle {
  sway, // suave balanceo lateral
  spin, // giro continuo (ideal para girasol)
  pulse, // latido/zoom sutil (ideal para rosa)
}

extension FlowerThemeDefaults on FlowerTheme {
  /// Suggested default animation per theme
  FlowerAnimationStyle get defaultAnimation {
    switch (this) {
      case FlowerTheme.sunflower:
        return FlowerAnimationStyle.spin;
      case FlowerTheme.rose:
        return FlowerAnimationStyle.pulse;
      case FlowerTheme.daisy:
        return FlowerAnimationStyle.sway;
    }
  }
}
