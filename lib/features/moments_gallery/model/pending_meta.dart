import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';

class PendingMeta {
  PendingMeta({required this.album, this.description, this.trackId});

  final AlbumCategory album;
  final String? description;
  final String? trackId; // optional Jamendo track id
}
