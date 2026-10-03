import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:yellow_flowers/data/music_service/firebase_music_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/data/model/song_audio_source.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/widgets/glass_card.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

/// Género de Firestore (`songs.genre`) para los sonidos de la naturaleza.
const kNatureGenre = 'nature';

/// Hoja de "Sonidos para leer": música relajante y sonidos de la naturaleza
/// que siguen sonando en segundo plano, con controles en la notificación.
Future<void> showAmbientSounds(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AmbientSoundsSheet(),
  );
}

class _AmbientSoundsSheet extends StatefulWidget {
  const _AmbientSoundsSheet();

  @override
  State<_AmbientSoundsSheet> createState() => _AmbientSoundsSheetState();
}

class _AmbientSoundsSheetState extends State<_AmbientSoundsSheet> {
  final _player = sl<AudioPlayer>();
  final _music = sl<FirebaseMusicService>();
  late final Future<(List<Song>, List<Song>)> _load = _fetch();

  Future<(List<Song>, List<Song>)> _fetch() async {
    final results = await Future.wait([
      _music.getSongsByMood(Mood.relaxed),
      _music.getSongsByGenre(kNatureGenre),
    ]);
    bool playable(Song s) => s.audioUrl.isNotEmpty;
    return (
      results[0].where(playable).toList(),
      results[1].where(playable).toList(),
    );
  }

  /// Reproduce la lista completa desde [index] en bucle: la notificación
  /// muestra anterior / pausa / siguiente.
  Future<void> _playList(List<Song> songs, int index) async {
    HapticFeedback.selectionClick();
    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
            children: songs.map((s) => s.audioSource).toList()),
        initialIndex: index,
      );
      await _player.setLoopMode(LoopMode.all);
      await _player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reproducir este sonido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C1236), Color(0xFF3A1D33)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _warmWhite.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text('Sonidos para leer 🎧',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _warmWhite)),
            const SizedBox(height: 4),
            Text('Siguen sonando aunque cierres la app',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: _warmWhite.withAlpha(150))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _NowPlayingBar(player: _player),
            ),
            Expanded(
              child: FutureBuilder<(List<Song>, List<Song>)>(
                future: _load,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                        child: CircularProgressIndicator(color: _gold));
                  }
                  if (snap.hasError) {
                    return _hint('No pudimos cargar los sonidos.\n'
                        'Revisa tu conexión e inténtalo de nuevo.');
                  }
                  final (relaxing, nature) = snap.data!;
                  return ListView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _section('MÚSICA RELAJANTE', relaxing),
                      const SizedBox(height: 12),
                      _section('NATURALEZA 🌿', nature),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Song> songs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _gold)),
        ),
        if (songs.isEmpty)
          Text('Aún no hay sonidos en esta categoría.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: _warmWhite.withAlpha(140)))
        else
          StreamBuilder<SequenceState?>(
            stream: _player.sequenceStateStream,
            builder: (context, snap) {
              final currentId =
                  (snap.data?.currentSource?.tag as MediaItem?)?.id;
              return Column(
                children: [
                  for (var i = 0; i < songs.length; i++)
                    _SoundTile(
                      song: songs[i],
                      active: currentId == songs[i].mediaItem.id,
                      onTap: () => _playList(songs, i),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _hint(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  color: _warmWhite.withAlpha(160), height: 1.5)),
        ),
      );
}

class _SoundTile extends StatelessWidget {
  const _SoundTile(
      {required this.song, required this.active, required this.onTap});
  final Song song;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          dark: true,
          radius: 18,
          glow: active,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(active ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                  color: _gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700, color: _warmWhite)),
                    if (song.artist.isNotEmpty)
                      Text(song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: _warmWhite.withAlpha(150))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra con la pista actual y los mismos controles que la notificación.
class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.player});
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
      stream: player.sequenceStateStream,
      builder: (context, seqSnap) {
        final item = seqSnap.data?.currentSource?.tag as MediaItem?;
        if (item == null) return const SizedBox.shrink();
        return GlassCard(
          dark: true,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.skip_previous_rounded, color: _warmWhite),
                onPressed: player.hasPrevious ? player.seekToPrevious : null,
              ),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, s) {
                  final playing = s.data?.playing ?? false;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(
                        playing
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: _gold),
                    onPressed: playing ? player.pause : player.play,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: _warmWhite),
                onPressed: player.hasNext ? player.seekToNext : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, color: _warmWhite)),
              ),
              IconButton(
                icon:
                    Icon(Icons.stop_rounded, color: _warmWhite.withAlpha(170)),
                onPressed: player.stop,
              ),
            ],
          ),
        );
      },
    );
  }
}
