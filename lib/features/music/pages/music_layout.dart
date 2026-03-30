import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/data/model/song.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/widgets/music_list.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

// ─── Mood visual palettes ──────────────────────────────────────────────────────
const _moodGradients = <Mood, List<Color>>{
  Mood.happy:     [Color(0xFFFFF8E1), Color(0xFFFFD740)],
  Mood.relaxed:   [Color(0xFFE8F5E9), Color(0xFF81C784)],
  Mood.romantic:  [Color(0xFFFCE4EC), Color(0xFFF06292)],
  Mood.motivated: [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
  Mood.nostalgic: [Color(0xFFEDE7F6), Color(0xFF9575CD)],
};

const _moodDescriptions = <Mood, String>{
  Mood.happy:     'Alegría y luz',
  Mood.relaxed:   'Calma interior',
  Mood.romantic:  'Corazón abierto',
  Mood.motivated: 'Energía total',
  Mood.nostalgic: 'Recuerdos bellos',
};

// ═══════════════════════════════════════════════════════════════════════════════
// MUSIC LAYOUT
// ═══════════════════════════════════════════════════════════════════════════════

class MusicLayout extends StatefulWidget {
  const MusicLayout({super.key});

  @override
  State<MusicLayout> createState() => _MusicLayoutState();
}

class _MusicLayoutState extends State<MusicLayout>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _listCtrl;
  bool _moodSynced = false;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMood());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  // Sync MusicBloc's selected mood with the global MoodController on first load
  void _syncMood() {
    if (!mounted || _moodSynced) return;
    _moodSynced = true;
    final moodCtrl = context.read<MoodController>();
    final bloc = context.read<MusicBloc>();
    if (bloc.selectedMood != moodCtrl.mood) {
      bloc.selectMood(moodCtrl.mood);
    }
  }

  // User tapped a mood card → update both bloc and global controller
  void _onMoodSelected(Mood mood) {
    context.read<MusicBloc>().selectMood(mood);
    context.read<MoodController>().setMood(mood);
    _listCtrl.reset();
    _listCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: PremiumDesign.cream,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: PremiumDesign.softText),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Text(
              'Tu Música',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w800,
                color: PremiumDesign.softText,
              ),
            ),
            centerTitle: true,
          ),
          body: AnimatedBackground(
            decorationCount: 5,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mood section label ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        PremiumDesign.s24, PremiumDesign.s12,
                        PremiumDesign.s24, PremiumDesign.s8),
                    child: Text(
                      'ELIGE TU ESTADO DE ÁNIMO',
                      style: PremiumDesign.sansLabel,
                    ),
                  ),

                  // ── Mood cards ────────────────────────────────────────────
                  SizedBox(
                    height: 102,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: PremiumDesign.s24),
                      itemCount: Mood.values.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        final mood = Mood.values[i];
                        return _MoodCard(
                          mood: mood,
                          isSelected: model.selectedMood == mood,
                          onTap: () => _onMoodSelected(mood),
                          animCtrl: _headerCtrl,
                          index: i,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: PremiumDesign.s16),

                  // ── Scrollable content with Refresh indicator ────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFE91E8C),
                      onRefresh: () async {
                        await model.retry();
                      },
                      child: CustomScrollView(
                        slivers: [
                          // ── Featured daily recommendation ─────────────────────────
                          if (model.dailyRecommendation != null)
                            SliverToBoxAdapter(
                              child: FadeTransition(
                                opacity: _listCtrl,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      PremiumDesign.s24, 0,
                                      PremiumDesign.s24, PremiumDesign.s16),
                                  child: _FeaturedCard(
                                    song: model.dailyRecommendation!,
                                    isPlaying: model.currentSong?.id ==
                                            model.dailyRecommendation!.id &&
                                        model.isPlaying,
                                    onTap: () {
                                      final s = model.dailyRecommendation!;
                                      model.selectSong(s);
                                      model.playSong(s);
                                    },
                                  ),
                                ),
                              ),
                            ),

                          // ── "Canciones para ti" section label ────────────────────
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  PremiumDesign.s24, 0,
                                  PremiumDesign.s24, PremiumDesign.s12),
                              child: Row(
                                children: [
                                  Text(
                                    'Canciones para ti',
                                    style: PremiumDesign.serifSubHeading
                                        .copyWith(fontSize: 20),
                                  ),
                                  const Spacer(),
                                  if (model.isLoading)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFE91E8C),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // ── Song list ─────────────────────────────────────────────
                          SliverFillRemaining(
                            hasScrollBody: true,
                            child: FadeTransition(
                              opacity: _listCtrl,
                              child: const MusicList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Now-playing mini bar ──────────────────────────────────
                  if (model.currentSong != null)
                    _NowPlayingBar(model: model),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOOD CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
    required this.animCtrl,
    required this.index,
  });

  final Mood mood;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animCtrl;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = _moodGradients[mood]!;
    final desc = _moodDescriptions[mood]!;

    // Staggered fade-slide entry
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final fade = CurvedAnimation(
      parent: animCtrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: animCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic)),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: isSelected ? 90 : 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [colors[1], colors[1].withValues(alpha: 0.85)]
                    : colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? colors[1]
                    : Colors.white.withValues(alpha: 0.6),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors[1].withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontSize: isSelected ? 26 : 22),
                  child: Text(mood.emoji),
                ),
                const SizedBox(height: 5),
                Text(
                  mood.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : PremiumDesign.softText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : PremiumDesign.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FEATURED DAILY RECOMMENDATION CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 138,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Album art background
              song.coverUrl.isNotEmpty
                  ? Image.network(
                      song.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackBg(),
                    )
                  : _fallbackBg(),

              // Frosted overlay on the left
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.82),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gold label
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 10,
                                  color: Color(0xFFD4AF37)),
                              const SizedBox(width: 4),
                              Text(
                                'CANCIÓN DEL DÍA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Play / Pause button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? const Color(0xFFE91E8C)
                            : Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isPlaying
                                ? const Color(0xFFE91E8C)
                                    .withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isPlaying
                            ? Colors.white
                            : const Color(0xFFE91E8C),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackBg() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAD1457), Color(0xFFE91E8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOW PLAYING MINI BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.model});

  final MusicBloc model;

  @override
  Widget build(BuildContext context) {
    final song = model.currentSong!;
    final total =
        song.duration.inSeconds > 0 ? song.duration.inSeconds : 1;
    final progress =
        (model.position.inSeconds / total).clamp(0.0, 1.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(
                  color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress line
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFE91E8C)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    // Cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: song.coverUrl.isNotEmpty
                          ? Image.network(
                              song.coverUrl,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _coverPlaceholder(),
                            )
                          : _coverPlaceholder(),
                    ),
                    const SizedBox(width: 10),

                    // Title + artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: PremiumDesign.softText,
                            ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: PremiumDesign.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded,
                          color: Color(0xFFE91E8C), size: 22),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: model.skipPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        model.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: const Color(0xFFE91E8C),
                        size: 36,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
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
                          color: Color(0xFFE91E8C), size: 22),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: model.skipNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF8BBD0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note_rounded,
            color: Color(0xFFE91E8C), size: 20),
      );
}
