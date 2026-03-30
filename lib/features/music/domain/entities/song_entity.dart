class SongEntity {

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    required this.genre,
  });
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String coverUrl;
  final Duration duration;
  final String genre;
}
