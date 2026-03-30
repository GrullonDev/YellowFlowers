import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/widgets/music_list.dart';
import 'package:yellow_flowers/features/music/widgets/premium_music_player.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class MusicLayout extends StatefulWidget {
  const MusicLayout({super.key});

  @override
  State<MusicLayout> createState() => _MusicLayoutState();
}

class _MusicLayoutState extends State<MusicLayout> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicBloc>(
      builder: (context, model, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Música y Ambiente',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w800,
              color: PremiumDesign.softText,
            ),
          ),
          centerTitle: true,
        ),
        body: AnimatedBackground(
          decorationCount: 6,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: PremiumDesign.s16),
                
                // Mood Selector Premium
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                  child: Row(
                    children: Mood.values.map((mood) {
                      final isSelected = model.selectedMood == mood;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ChoiceChip(
                            label: Text(mood.label),
                            selected: isSelected,
                            onSelected: (_) {
                              model.selectMood(mood);
                              _fadeController.reset();
                              _fadeController.forward();
                            },
                            backgroundColor: Colors.white.withValues(alpha: 0.5),
                            selectedColor: PremiumDesign.softText,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : PremiumDesign.softText,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : PremiumDesign.softText.withValues(alpha: 0.1),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: PremiumDesign.s24),

                // Recomendación Diaria o Player
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: PremiumMusicPlayer(
                      player: di.sl<AudioPlayer>(),
                    ),
                  ),
                ),

                const SizedBox(height: PremiumDesign.s24),

                // Lista de Canciones
                const Expanded(
                  child: MusicList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
