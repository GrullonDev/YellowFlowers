/// Domain-level Mood enum for music recommendations.
/// (Moved out of data layer to avoid domain -> data dependency.)
enum Mood { happy, relaxed, romantic, motivated, nostalgic }

extension MoodUI on Mood {
  String get label {
    switch (this) {
      case Mood.happy: return 'Feliz';
      case Mood.relaxed: return 'Tranquila';
      case Mood.romantic: return 'Romántica';
      case Mood.motivated: return 'Motivada';
      case Mood.nostalgic: return 'Nostálgica';
    }
  }

  String get emoji {
    switch (this) {
      case Mood.happy: return '💛';
      case Mood.relaxed: return '🌿';
      case Mood.romantic: return '💖';
      case Mood.motivated: return '🚀';
      case Mood.nostalgic: return '🌙';
    }
  }
}
