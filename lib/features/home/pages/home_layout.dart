import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, _) => Scaffold(
        backgroundColor: PremiumDesign.cream,
        extendBodyBehindAppBar: true,
        body: _GradientScaffold(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header emocional — zona de bienvenida
              const SliverToBoxAdapter(child: _EmotionalHero()),

              // Corazón de la Home: Recomendación inteligente destacada
              SliverToBoxAdapter(
                child: _StaggeredFade(
                  controller: _staggerController,
                  index: 1,
                  child: const _FeaturedGem(),
                ),
              ),

              // Sección diaria: ánimo + bienestar rápido
              SliverToBoxAdapter(
                child: _StaggeredFade(
                  controller: _staggerController,
                  index: 2,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(PremiumDesign.s24,
                        PremiumDesign.s24, PremiumDesign.s24, 0),
                    child: _DailySection(),
                  ),
                ),
              ),

              // Jardín de experiencias
              SliverToBoxAdapter(
                child: _StaggeredFade(
                  controller: _staggerController,
                  index: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        PremiumDesign.s24,
                        PremiumDesign.s32,
                        PremiumDesign.s24,
                        PremiumDesign.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu jardín',
                          style:
                              PremiumDesign.serifHeading.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elige cómo vivir este momento',
                          style: PremiumDesign.sansBody.copyWith(
                            fontSize: 13,
                            color: PremiumDesign.secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    PremiumDesign.s24, 0, PremiumDesign.s24, PremiumDesign.s48),
                sliver: SliverList.separated(
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: PremiumDesign.s12),
                  itemCount: model.menuItems.length,
                  itemBuilder: (context, i) => _StaggeredFade(
                    controller: _staggerController,
                    index: 4 + i,
                    child: _ExperienceTile(
                      item: model.menuItems[i],
                      style: _tileStyleForIndex(i),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  const _StaggeredFade({
    required this.controller,
    required this.index,
    required this.child,
  });
  final AnimationController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final fadeOut = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fadeOut,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FONDO DEGRADADO PREMIUM
// ═══════════════════════════════════════════════════════════════════════════════

class _GradientScaffold extends StatelessWidget {
  const _GradientScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      decorationCount: 15,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERO EMOCIONAL
// ═══════════════════════════════════════════════════════════════════════════════

class _EmotionalHero extends StatefulWidget {
  const _EmotionalHero();

  @override
  State<_EmotionalHero> createState() => _EmotionalHeroState();
}

class _EmotionalHeroState extends State<_EmotionalHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.watch<MoodController>().mood;
    final personalization = di.sl<PersonalizationService>();
    final name = personalization.getUserName() ?? 'hermosa';
    final greeting = _greetingForTime(name);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _HeroBackground(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(PremiumDesign.s24,
                  PremiumDesign.s16, PremiumDesign.s24, PremiumDesign.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra superior: logo + acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'flores amarillas',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: PremiumDesign.secondaryText,
                        ),
                      ),
                      _MoodBadge(mood: mood),
                    ],
                  ),

                  const SizedBox(height: PremiumDesign.s32),

                  // Decoración floral pequeña
                  const _FloralAccent(),

                  const SizedBox(height: PremiumDesign.s16),

                  // Saludo principal
                  Text(
                    greeting.line1,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesign.softText,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    greeting.line2,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFB5474E),
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: PremiumDesign.s12),

                  // Fecha
                  Text(
                    _formattedDate(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: PremiumDesign.secondaryText.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GEMA DESTACADA: CORAZÓN DE LA HOME
// ═══════════════════════════════════════════════════════════════════════════════

class _FeaturedGem extends StatelessWidget {
  const _FeaturedGem();

  @override
  Widget build(BuildContext context) {
    final recommendation = di.sl<PersonalizationService>().getRecommendation();
    final parts = recommendation.split('*');
    final p1 = parts[0];
    final p2 = parts.length > 1 ? parts[1] : '';
    final p3 = parts.length > 2 ? parts[2] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s24),
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: PremiumDesign.premiumRadius,
            boxShadow: [
              ...PremiumDesign.premiumShadow,
              if (DateTime.now().hour >= 18 || DateTime.now().hour < 6)
                ...PremiumDesign.goldGlow,
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4AF37).withValues(alpha: 0.12),
                        const Color(0xFFD4AF37).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PremiumDesign.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded,
                              color: Color(0xFFD4AF37), size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PARA TI HOY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PremiumDesign.s16),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          color: PremiumDesign.softText,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(text: p1),
                          if (p2.isNotEmpty)
                            TextSpan(
                              text: p2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB5474E),
                              ),
                            ),
                          TextSpan(text: p3),
                        ],
                      ),
                    ),
                    const SizedBox(height: PremiumDesign.s20),
                    _PremiumActionButton(
                      label: 'Explorar ahora',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final model = context.read<HomeBloc>();
                        if (model.menuItems.isNotEmpty) {
                          Navigator.of(context).push(
                              PremiumTransitions.fadeThrough(
                                  model.menuItems[0].destination));
                        }
                      },
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
}

class _PremiumActionButton extends StatefulWidget {
  const _PremiumActionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3E2723), Color(0xFF2D1B18)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E2723).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: child,
    );
  }
}

class _FloralAccent extends StatelessWidget {
  const _FloralAccent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _petalDot(const Color(0xFFFFB300), 8),
        const SizedBox(width: 5),
        _petalDot(const Color(0xFFE91E8C), 6),
        const SizedBox(width: 5),
        _petalDot(const Color(0xFF7E57C2), 5),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 1,
          color: const Color(0xFFE0C8D0).withValues(alpha: 0.6),
        ),
      ],
    );
  }

  Widget _petalDot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final info = _moodInfo(mood);
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: info.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: info.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              info.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: info.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECCIÓN DIARIA COMPACTA
// ═══════════════════════════════════════════════════════════════════════════════

class _DailySection extends StatelessWidget {
  const _DailySection();

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WellnessController>();
    final last7 = wc.last7Days();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Text(
          'Cómo te sientes',
          style: PremiumDesign.serifSubHeading.copyWith(fontSize: 18),
        ),
        const SizedBox(height: PremiumDesign.s16),

        // Chips de ánimo (horizontal scroll, sin card)
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: Emotion.values.map((e) {
              final isSelected = wc.emotionOf(wc.todayKey) == e;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _EmotionPill(
                  emotion: e,
                  isSelected: isSelected,
                  onTap: () => wc.setEmotionToday(e),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: PremiumDesign.s16),

        // Barra de 7 días (compacta, sin card)
        Row(
          children: [
            Text(
              'Esta semana',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: PremiumDesign.secondaryText.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 8,
                child: Row(
                  children: List.generate(7, (i) {
                    final emo = last7[i];
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 6 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: _emotionColor(emo),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: PremiumDesign.s20),

        // Acciones rápidas de bienestar (texto + icono, sin card)
        Row(
          children: [
            _QuickAction(
              icon: Icons.air_rounded,
              label: 'Respirar',
              color: const Color(0xFF43A047),
              onTap: () => _breathingDialog(context),
            ),
            const SizedBox(width: PremiumDesign.s12),
            _QuickAction(
              icon: Icons.auto_awesome_rounded,
              label: 'Afirmación',
              color: PremiumDesign.radiantGold,
              onTap: () => _affirmationDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmotionPill extends StatefulWidget {
  const _EmotionPill({
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });
  final Emotion emotion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_EmotionPill> createState() => _EmotionPillState();
}

class _EmotionPillState extends State<_EmotionPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = _emotionColor(widget.emotion);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: PremiumDesign.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? color : color.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Text(
            _emotionLabel(widget.emotion),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              color: widget.isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPERIENCE TILES — JARDÍN
// ═══════════════════════════════════════════════════════════════════════════════

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.item, required this.style});
  final dynamic item;
  final _TileStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context)
            .push(PremiumTransitions.fadeThrough(item.destination));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: PremiumDesign.premiumRadius,
          boxShadow: PremiumDesign.softShadow,
        ),
        child: Row(
          children: [
            // Acento lateral de color
            Container(
              width: 5,
              height: 80,
              decoration: BoxDecoration(
                color: style.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(PremiumDesign.cardRadius),
                  bottomLeft: Radius.circular(PremiumDesign.cardRadius),
                ),
              ),
            ),
            const SizedBox(width: PremiumDesign.s16),
            // Ícono
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: style.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: style.accentColor, size: 24),
            ),
            const SizedBox(width: PremiumDesign.s16),
            // Texto
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: PremiumDesign.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: PremiumDesign.softText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: PremiumDesign.secondaryText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: PremiumDesign.s20),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: PremiumDesign.secondaryText.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileStyle {
  const _TileStyle({required this.accentColor});
  final Color accentColor;
}

_TileStyle _tileStyleForIndex(int index) {
  const colors = [
    Color(0xFFFFB300), // dorado
    Color(0xFFE91E8C), // rosa
    Color(0xFF43A047), // verde
    Color(0xFF7E57C2), // lavanda
    Color(0xFF0097A7), // aqua
  ];
  return _TileStyle(accentColor: colors[index % colors.length]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

class _Greeting {
  const _Greeting(this.line1, this.line2);
  final String line1;
  final String line2;
}

_Greeting _greetingForTime(String name) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    return _Greeting('Buenos días,', '$name.');
  } else if (hour >= 12 && hour < 18) {
    return _Greeting('Buenas tardes,', '$name.');
  } else if (hour >= 18 && hour < 22) {
    return _Greeting('Buenas noches,', '$name.');
  } else {
    return _Greeting('Descansa bien,', '$name.');
  }
}

String _formattedDate() {
  final now = DateTime.now();
  const months = [
    '',
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  const days = [
    '',
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  final dayName = days[now.weekday];
  return '${dayName.substring(0, 1).toUpperCase()}${dayName.substring(1)}, '
      '${now.day} de ${months[now.month]}';
}

class _MoodInfo {
  const _MoodInfo(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;
}

_MoodInfo _moodInfo(Mood mood) {
  switch (mood) {
    case Mood.happy:
      return const _MoodInfo('💛', 'Alegre', Color(0xFFFFB300));
    case Mood.relaxed:
      return const _MoodInfo('🌿', 'Tranquila', Color(0xFF43A047));
    case Mood.romantic:
      return const _MoodInfo('💖', 'Enamorada', Color(0xFFE91E8C));
    case Mood.motivated:
      return const _MoodInfo('✨', 'Motivada', Color(0xFFF57C00));
    case Mood.nostalgic:
      return const _MoodInfo('🌙', 'Nostálgica', Color(0xFF7E57C2));
  }
}

Color _emotionColor(Emotion? e) {
  switch (e) {
    case Emotion.happy:
      return const Color(0xFFFFB300);
    case Emotion.relaxed:
      return const Color(0xFF00ACC1);
    case Emotion.romantic:
      return const Color(0xFFE91E8C);
    case Emotion.motivated:
      return const Color(0xFFF57C00);
    case Emotion.nostalgic:
      return const Color(0xFF7E57C2);
    default:
      return const Color(0xFFBDBDBD);
  }
}

String _emotionLabel(Emotion e) {
  switch (e) {
    case Emotion.happy:
      return 'Feliz 💛';
    case Emotion.relaxed:
      return 'Tranquila 🌿';
    case Emotion.romantic:
      return 'Romántica 💖';
    case Emotion.motivated:
      return 'Motivada ✨';
    case Emotion.nostalgic:
      return 'Nostálgica 🌙';
  }
}

void _breathingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Respiración 4-4-4',
        style: PremiumDesign.serifSubHeading.copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Inhala 4 segundos\nSostén 4 segundos\nExhala 4 segundos\n\nRepite 5 veces y siente la calma 🌬️',
        style: PremiumDesign.sansBody.copyWith(fontSize: 14, height: 1.7),
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(
          child: FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Listo 🌸'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

void _affirmationDialog(BuildContext context) {
  final name = di.sl<PersonalizationService>().getUserName() ?? 'hermosa';
  final affirmations = [
    'Eres suficiente tal como eres, $name.',
    'Mereces amor, paz y todo lo hermoso, $name.',
    'Eres fuerte, capaz y llena de luz.',
    'Cada día traes algo valioso al mundo, $name.',
    'Tu presencia importa y marca la diferencia.',
  ];
  final text = affirmations[DateTime.now().day % affirmations.length];
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✦',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            'Tu afirmación',
            style: PremiumDesign.serifSubHeading.copyWith(fontSize: 20),
          ),
        ],
      ),
      content: Text(
        '"$text"',
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: PremiumDesign.softText,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Gracias 💛',
              style: PremiumDesign.sansLabel
                  .copyWith(color: PremiumDesign.radiantGold),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
