import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/utils/app_theme.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_screen.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // 1. Dynamic Background
              _AnimatedBackground(controller: _bgController),

              // 2. Content
              SafeArea(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Area
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const _HeaderGreeting(),
                          const SizedBox(height: 24),
                          const _DailyDoseOfLove(),
                          const SizedBox(height: 32),
                          Text(
                            "¿Cómo te sientes hoy?",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          const _MoodCheckIn(),
                          const SizedBox(height: 32),
                          Text(
                            "Explora tu Jardín",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    // Grid Menu
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = model.menuItems[index];
                            return _MenuCard(
                              title: item.title,
                              icon: item.icon,
                              color: index % 2 == 0
                                  ? AppTheme.leafGreen
                                  : AppTheme.accentPink,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => item.destination,
                                ),
                              ),
                            );
                          },
                          childCount: model.menuItems.length,
                        ),
                      ),
                    ),

                    const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderGreeting extends StatelessWidget {
  const _HeaderGreeting();

  @override
  Widget build(BuildContext context) {
    // Determine greeting based on time
    final hour = DateTime.now().hour;
    String greeting = "Buenos Días";
    if (hour >= 12) greeting = "Buenas Tardes";
    if (hour >= 19) greeting = "Buenas Noches";

    return Column(
      children: [
        Text(
          "$greeting, Bella ✨",
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DailyDoseOfLove extends StatelessWidget {
  const _DailyDoseOfLove();

  static const List<String> _quotes = [
    "Eres suficiente tal como eres. 💖",
    "Tu luz ilumina el mundo. ✨",
    "Mereces todo el amor que das. 🌸",
    "Hoy es un día perfecto para brillar. ☀️",
    "Confía en tu magia interior. 🦋",
  ];

  @override
  Widget build(BuildContext context) {
    // Simple random quote (could be cached per day in a real app)
    final quote = _quotes[DateTime.now().day % _quotes.length];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sunnyGold.withValues(alpha: 0.15),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded,
              color: AppTheme.sunnyGold, size: 32),
          const SizedBox(height: 8),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCheckIn extends StatelessWidget {
  const _MoodCheckIn();

  void _openMoodFlower(BuildContext context, Mood mood) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlowerScreen(
          recipientName: "Mí", // Self-love default
          mood: mood,
          theme: FlowerTheme.daisy,
          fancyName: true,
          animationStyle: FlowerAnimationStyle.sway,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MoodIcon(
          emoji: "😄",
          label: "Feliz",
          onTap: () => _openMoodFlower(context, Mood.joy),
        ),
        _MoodIcon(
          emoji: "😌",
          label: "Calma",
          onTap: () => _openMoodFlower(context, Mood.calm),
        ),
        _MoodIcon(
          emoji: "🥰",
          label: "Amada",
          onTap: () => _openMoodFlower(context, Mood.passion),
        ),
      ],
    );
  }
}

class _MoodIcon extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _MoodIcon({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: color.withValues(alpha: 1.0),
                    size: 32), // Darker version for icon
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.backgroundCream,
                Color.lerp(
                  AppTheme.backgroundCream,
                  const Color(0xFFFFE0B2), // Soft Orange
                  math.sin(controller.value * math.pi) * 0.5 + 0.5,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: List.generate(15, (index) {
              final rnd = math.Random(index);
              final size = rnd.nextDouble() * 30 + 10;
              final top = rnd.nextDouble() * MediaQuery.of(context).size.height;
              final left = rnd.nextDouble() * MediaQuery.of(context).size.width;
              final speed = rnd.nextDouble() * 0.5 + 0.5;
              final moveY =
                  math.sin((controller.value * 2 * math.pi * speed) + index) *
                      20;

              return Positioned(
                top: top + moveY,
                left: left,
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    index % 3 == 0 ? Icons.favorite : Icons.local_florist,
                    size: size,
                    color: index % 2 == 0
                        ? AppTheme.accentPink
                        : AppTheme.primaryYellow,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
