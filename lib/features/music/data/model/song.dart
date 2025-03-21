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
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      audioUrl: json['audio_url'],
      coverUrl: json['cover_url'],
      duration: Duration(seconds: json['duration']),
      genre: json['genre'],
    );
  }

  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final Duration duration;
  final String genre;
}
