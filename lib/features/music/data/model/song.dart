class Song {
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    required this.genre,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      duration: Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0),
      genre: json['genre'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'duration': duration.inSeconds,
      'genre': genre,
    };
  }

  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final Duration duration;
  final String genre;
}
