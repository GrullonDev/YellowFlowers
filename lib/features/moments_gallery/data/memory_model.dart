import 'dart:convert';

class Memory {
  Memory({
    required this.fileName,
    required this.albumId,
    required this.createdAt,
    this.description,
    this.trackId,
  });

  factory Memory.fromMap(Map<String, dynamic> map) => Memory(
        fileName: map['file'] as String,
        albumId: map['album'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (map['createdAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch),
        description: map['description'] as String?,
        trackId: map['trackId'] as String?,
      );
  final String fileName; // stored relative to memories directory
  final String albumId;
  final DateTime createdAt;
  final String? description;
  final String? trackId; // optional Jamendo track id associated to this memory

  Map<String, dynamic> toMap() => {
        'file': fileName,
        'album': albumId,
        'createdAt': createdAt.millisecondsSinceEpoch,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (trackId != null && trackId!.isNotEmpty) 'trackId': trackId,
      };

  static String encodeList(List<Memory> list) =>
      jsonEncode(list.map((e) => e.toMap()).toList());
  static List<Memory> decodeList(String raw) {
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map((m) => Memory.fromMap(m))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }
}
