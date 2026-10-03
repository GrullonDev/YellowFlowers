import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:yellow_flowers/features/music/data/model/song.dart';

/// Con just_audio_background activo, toda fuente de audio debe llevar un
/// [MediaItem]: es lo que se muestra en la notificación / pantalla de bloqueo.
extension SongAudioSource on Song {
  MediaItem get mediaItem => MediaItem(
        id: id.isEmpty ? audioUrl : id,
        title: title.isEmpty ? 'Amarillas' : title,
        artist: artist.isEmpty ? null : artist,
        album: 'Amarillas',
        duration: duration == Duration.zero ? null : duration,
        artUri: coverUrl.isEmpty ? null : Uri.tryParse(coverUrl),
      );

  UriAudioSource get audioSource =>
      AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem);
}
