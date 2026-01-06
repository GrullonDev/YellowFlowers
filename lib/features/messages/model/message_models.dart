enum MessageCategory {
  love,
  friendship,
  selfEsteem,
  family,
  occasions,
  community,
}

extension MessageCategoryX on MessageCategory {
  String get label {
    switch (this) {
      case MessageCategory.love:
        return 'Amor 💕';
      case MessageCategory.friendship:
        return 'Amistad 👯‍♀️';
      case MessageCategory.selfEsteem:
        return 'Autoestima ✨';
      case MessageCategory.family:
        return 'Familia 👨‍👩‍👧';
      case MessageCategory.occasions:
        return 'Ocasiones 🎂';
      case MessageCategory.community:
        return 'Comunidad 💬';
    }
  }

  String get emoji {
    switch (this) {
      case MessageCategory.love:
        return '💖';
      case MessageCategory.friendship:
        return '🌼';
      case MessageCategory.selfEsteem:
        return '✨';
      case MessageCategory.family:
        return '🌷';
      case MessageCategory.occasions:
        return '🎉';
      case MessageCategory.community:
        return '💬';
    }
  }
}

class SpecialMessage {
  SpecialMessage({
    required this.text,
    required this.category,
    DateTime? createdAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();
  final String text;
  final MessageCategory category;
  final DateTime createdAt;
  final bool isFavorite;

  SpecialMessage copyWith({
    String? text,
    MessageCategory? category,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return SpecialMessage(
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
