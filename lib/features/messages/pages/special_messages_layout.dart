import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/features/messages/widgets/message_card.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/experience/pages/immersive_experience_page.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';

class SpecialMessagesLayout extends StatefulWidget {
  const SpecialMessagesLayout({super.key});

  @override
  State<SpecialMessagesLayout> createState() => _SpecialMessagesLayoutState();
}

class _SpecialMessagesLayoutState extends State<SpecialMessagesLayout> with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialMessagesBloc>(
      builder: (context, model, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, model),
          body: AnimatedBackground(
            decorationCount: 8,
            child: SafeArea(
              child: TabBarView(
                children: [
                  _MessagesTab(model: model, controller: _listController),
                  _FavoritesTab(model: model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SpecialMessagesBloc model) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Mensajes Especiales',
        style: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w800,
          color: PremiumDesign.softText,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Ciclo y Música',
          icon: const Icon(Icons.auto_awesome_rounded, color: PremiumDesign.softText),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CycleMusicPage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        dividerColor: Colors.transparent,
        indicatorColor: PremiumDesign.premiumGold,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: PremiumDesign.softText,
        unselectedLabelColor: PremiumDesign.secondaryText,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: 'Explorar'),
          Tab(text: 'Favoritos'),
        ],
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.model, required this.controller});
  final SpecialMessagesBloc model;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: PremiumDesign.s16),
        
        // Categorías (Chips Premium)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
          child: Row(
            children: MessageCategory.values.map((c) {
              final isSelected = c == model.selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.label),
                  selected: isSelected,
                  onSelected: (_) => model.setCategory(c),
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  selectedColor: PremiumDesign.softText,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : PremiumDesign.softText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : PremiumDesign.softText.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: PremiumDesign.s16),

        // Barra de recomendación contextual
        _PremiumRecommendationBar(model: model),

        const SizedBox(height: PremiumDesign.s16),

        // Campo de creación rápida (Glassmorphism)
        _QuickCreateBar(model: model),

        const SizedBox(height: PremiumDesign.s16),

        // Lista de Mensajes
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(PremiumDesign.s24, 0, PremiumDesign.s24, PremiumDesign.s24),
            itemCount: model.messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: PremiumDesign.s16),
            itemBuilder: (context, i) {
              final msg = model.messages[i];
              
              // Animación escalonada
              final animation = CurvedAnimation(
                parent: controller,
                curve: Interval(
                  (i * 0.05).clamp(0.0, 1.0),
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Column(
                    children: [
                      MessageCard(
                        text: msg.text,
                        isFavorite: msg.isFavorite,
                        onFavorite: () => model.toggleFavorite(i),
                        onSpeak: () => model.speak(i),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickCreateBar extends StatelessWidget {
  const _QuickCreateBar({required this.model});
  final SpecialMessagesBloc model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
      child: Container(
        padding: const EdgeInsets.all(PremiumDesign.s12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: model.controller,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Crea tu propio mensaje...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: PremiumDesign.secondaryText.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: PremiumDesign.softText,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  if (model.controller.text.isNotEmpty) {
                    model.addMessage(model.controller.text);
                    model.controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumRecommendationBar extends StatelessWidget {
  const _PremiumRecommendationBar({required this.model});
  final SpecialMessagesBloc model;

  @override
  Widget build(BuildContext context) {
    final mood = _moodForCategory(model.selected);
    final text = _contextualText(mood);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
      child: InkWell(
        onTap: () => _showMusicSuggestion(context, model.selected, null),
        child: Container(
          padding: const EdgeInsets.all(PremiumDesign.s16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [PremiumDesign.premiumGold.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.3)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PremiumDesign.premiumGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesign.softText,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PremiumDesign.premiumGold),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({required this.model});
  final SpecialMessagesBloc model;

  @override
  Widget build(BuildContext context) {
    if (model.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PremiumDesign.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(PremiumDesign.s24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              Text(
                'Aquí guardarás tus momentos especiales',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesign.softText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Colecciona los mensajes que más te lleguen al corazón.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: PremiumDesign.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final controller = DefaultTabController.of(context);
                  controller.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumDesign.softText,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  'Explorar mensajes',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(PremiumDesign.s24),
      itemCount: model.favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: PremiumDesign.s16),
      itemBuilder: (context, i) {
        final fav = model.favorites[i];
        return MessageCard(
          text: fav.text,
          isFavorite: true,
          onSpeak: () => model.speakMessage(fav),
          onFavorite: () {
            final idx = model.messages.indexWhere((m) =>
                m.text == fav.text && m.category == fav.category);
            if (idx != -1) model.toggleFavorite(idx);
          },
        );
      },
    );
  }
}

Future<void> _showMusicSuggestion(
    BuildContext context, MessageCategory category, String? sourceText) async {
  final mood = _moodForCategory(category);
  final bloc = di.sl<MusicBloc>();
  bloc.selectMood(mood);
  await Future.delayed(const Duration(milliseconds: 150));
  final song = bloc.dailyRecommendation;
  
  if (song == null) return;
  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.all(PremiumDesign.s24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(PremiumDesign.cardRadius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_sheetTitleForMood(mood),
                style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w800, color: PremiumDesign.softText)),
            const SizedBox(height: 16),
            Row(
              children: [
                if (song.coverUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(song.coverUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.music_note)),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(song.artist, style: GoogleFonts.plusJakartaSans(color: PremiumDesign.secondaryText)),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    bloc.playSong(song);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  style: IconButton.styleFrom(backgroundColor: PremiumDesign.softText),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  bloc.playSong(song);
                  Navigator.pop(ctx);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ImmersiveExperiencePage(
                      initialText: sourceText ?? 'Un momento especial',
                      mood: mood,
                    ),
                  ));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: PremiumDesign.premiumGold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Ver experiencia sugerida', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: PremiumDesign.premiumGold)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Mood _moodForCategory(MessageCategory c) {
  switch (c) {
    case MessageCategory.love: return Mood.romantic;
    case MessageCategory.friendship: return Mood.happy;
    case MessageCategory.selfEsteem: return Mood.motivated;
    case MessageCategory.family: return Mood.nostalgic;
    case MessageCategory.occasions: return Mood.happy;
    case MessageCategory.community: return Mood.relaxed;
  }
}

String _contextualText(Mood mood) {
  switch (mood) {
    case Mood.motivated: return '¡Hoy vas con todo! Esta canción te dará energía 🚀';
    case Mood.nostalgic: return 'Un momento para recordar... 🎶';
    case Mood.romantic: return 'Deja que el amor fluya con esta melodía 💖';
    case Mood.happy: return '¡Sonríe! Tu ánimo contagia alegría 💛';
    case Mood.relaxed: return 'Respira... este es tu momento de paz 🌿';
  }
}

String _sheetTitleForMood(Mood mood) {
  switch (mood) {
    case Mood.motivated: return 'Energía para ti ✨';
    case Mood.nostalgic: return 'Para recordar 🌙';
    case Mood.romantic: return 'Acompaña con amor 💖';
    case Mood.happy: return 'Música para brillar 💛';
    case Mood.relaxed: return 'Un respiro musical 🌿';
  }
}
