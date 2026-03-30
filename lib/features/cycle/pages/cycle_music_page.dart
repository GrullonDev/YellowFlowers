import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/widgets/music_list.dart';
import 'package:yellow_flowers/features/music/widgets/premium_music_player.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class CycleMusicPage extends StatelessWidget {
  const CycleMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: di.sl<MusicBloc>()),
        ChangeNotifierProvider.value(value: di.sl<CycleController>()),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: PremiumDesign.softText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Tu Ciclo y Ambiente',
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
            child: Consumer2<MusicBloc, CycleController>(
              builder: (context, musicModel, cycleModel, _) {
                return Column(
                  children: [
                    const SizedBox(height: PremiumDesign.s16),
                    
                    // Cycle Info Card
                    _CycleInfoCard(cycleModel: cycleModel),
                    
                    const SizedBox(height: PremiumDesign.s24),
                    
                    // Music Player
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
                      child: PremiumMusicPlayer(player: di.sl<AudioPlayer>()),
                    ),
                    
                    const SizedBox(height: PremiumDesign.s24),
                    
                    // Song List
                    const Expanded(
                      child: MusicList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CycleInfoCard extends StatelessWidget {
  const _CycleInfoCard({required this.cycleModel});
  final CycleController cycleModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
      padding: const EdgeInsets.all(PremiumDesign.s20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: PremiumDesign.premiumRadius,
        boxShadow: PremiumDesign.softShadow,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumDesign.premiumGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FASE ACTUAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesign.premiumGold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      cycleModel.currentPhaseLabel,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesign.softText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cycleModel.recommendation != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PremiumDesign.cream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PremiumDesign.premiumGold.withValues(alpha: 0.1)),
              ),
              child: Text(
                cycleModel.recommendation!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: PremiumDesign.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
