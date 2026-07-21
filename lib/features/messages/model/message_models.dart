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
    this.isUserComposed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SpecialMessage.fromJson(Map<String, dynamic> json) {
    return SpecialMessage(
      text: json['text'] as String? ?? '',
      category: MessageCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => MessageCategory.love,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isUserComposed: json['isUserComposed'] as bool? ?? true,
    );
  }
  final String text;
  final MessageCategory category;
  final DateTime createdAt;
  final bool isFavorite;

  /// True for messages the user wrote themselves (via addMessage), as
  /// opposed to the small built-in seed list. Only user-composed
  /// messages are persisted/synced — see SpecialMessagesBloc.
  final bool isUserComposed;

  SpecialMessage copyWith({
    String? text,
    MessageCategory? category,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isUserComposed,
  }) {
    return SpecialMessage(
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isUserComposed: isUserComposed ?? this.isUserComposed,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'category': category.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'isFavorite': isFavorite,
        'isUserComposed': isUserComposed,
      };



  /// Stable id for a user-composed message: used both as the Firestore
  /// document id and as the local-cache dedup key.
  String get syncId => createdAt.millisecondsSinceEpoch.toString();
}
