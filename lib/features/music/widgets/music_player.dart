import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({
    super.key,
    required this.model,
    this.isMiniPlayer = false,
  });

  final MusicBloc model;
  final bool isMiniPlayer;

  @override
  Widget build(BuildContext context) {
    return isMiniPlayer ? _MiniPlayer(model: model) : _FullPlayer(model: model);
  }
}

// ─── Mini Player ──────────────────────────────────────────────────────────────

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({required this.model});
  final MusicBloc model;

  @override
  Widget build(BuildContext context) {
    final song = model.currentSong!;
    final total = song.duration.inSeconds > 0 ? song.duration.inSeconds : 1;
    final progress = (model.position.inSeconds / total).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE4EC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFFB300)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _CoverImage(url: song.coverUrl, size: 44, radius: 8),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: const Color(0xFF795548),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    model.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFFE91E8C),
                    size: 32,
                  ),
                  onPressed: () {
                    if (model.isPlaying) {
                      model.pauseSong();
                    } else {
                      model.playSong(model.currentSong!);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded,
                      color: Color(0xFFE91E8C), size: 28),
                  onPressed: model.skipNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full Player ──────────────────────────────────────────────────────────────

class _FullPlayer extends StatelessWidget {
  const _FullPlayer({required this.model});
  final MusicBloc model;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final song = model.currentSong!;
    final total = song.duration.inSeconds > 0 ? song.duration.inSeconds : 1;
    final progress = (model.position.inSeconds / total).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE4EC)],
        ),
      ),
      child: Column(
        children: [
          // Cover art
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Hero(
                tag: 'music_cover_${song.id}',
                child: _CoverImage(
                  url: song.coverUrl,
                  size: double.infinity,
                  radius: 24,
                  shadow: true,
                ),
              ),
            ),
          ),

          // Song info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: const Color(0xFF795548),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF795548), size: 24),
                  tooltip: 'Volver a la lista',
                  onPressed: () {
                    model.pauseSong();
                    model.selectSong(
                        model.currentSong!); // keep selected but stop
                    // Navigate back is handled by layout
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar + timestamps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFE91E8C),
                    inactiveTrackColor:
                        const Color(0xFFE91E8C).withValues(alpha: 0.2),
                    thumbColor: const Color(0xFFE91E8C),
                    overlayColor:
                        const Color(0xFFE91E8C).withValues(alpha: 0.15),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (v) {
                      final target = Duration(
                          seconds: (v * song.duration.inSeconds).round());
                      model.seekTo(target);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(model.position),
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: const Color(0xFF795548),
                        ),
                      ),
                      Text(
                        _formatDuration(song.duration),
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: const Color(0xFF795548),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.skip_previous_rounded,
                  size: 36,
                  onPressed: model.skipPrevious,
                ),
                _PlayPauseButton(model: model, song: song),
                _ControlButton(
                  icon: Icons.skip_next_rounded,
                  size: 36,
                  onPressed: model.skipNext,
                ),
              ],
            ),
          ),

          // Genre chip
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Chip(
              label: Text(
                song.genre.toUpperCase(),
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: const Color(0xFFFFE4EC),
              side: const BorderSide(color: Color(0xFFFFC1D9)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.model, required this.song});
  final MusicBloc model;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF79B0), Color(0xFFE91E8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E8C).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          model.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
        onPressed: () {
          if (model.isPlaying) {
            model.pauseSong();
          } else {
            model.playSong(song);
          }
        },
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF6D4C41), size: size),
      onPressed: onPressed,
    );
  }
}

// ─── Cover Image ──────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.url,
    required this.size,
    required this.radius,
    this.shadow = false,
  });

  final String url;
  final double size;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        color: const Color(0xFFF8BBD0),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.music_note_rounded,
          color: Color(0xFFE91E8C), size: 36),
    );

    if (url.isEmpty) return placeholder;

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: size == double.infinity ? null : size,
        height: size == double.infinity ? null : size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder;
        },
      ),
    );

    if (shadow) {
      image = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: image,
      );
    }

    return image;
  }
}
