import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/design_system.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    super.key,
    required this.text,
    this.onFavorite,
    this.isFavorite = false,
    this.onSpeak,
    this.color,
    this.isLarge = false,
    this.variant = 0,
    this.categoryColor, // Color basado en el contexto emocional
  });

  final String text;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final VoidCallback? onSpeak;
  final Color? color;
  final bool isLarge;
  final int variant;
  final Color? categoryColor;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _pulseController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _likeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (!widget.isFavorite) {
      _likeController.forward(from: 0);
    } else {
      _likeController.reverse(from: 0.3);
    }
    widget.onFavorite?.call();
  }

  void _handleSpeak() {
    if (!mounted) return;
    setState(() => _isPlaying = !_isPlaying);
    widget.onSpeak?.call();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Contexto emocional: usar categoryColor si existe
    final Color baseAccent = widget.categoryColor ?? PremiumDesign.premiumGold;
    final List<Color> gradientColors = [
      Colors.white.withValues(alpha: 0.95),
      baseAccent.withValues(alpha: 0.08),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24), // Aire entre bloques
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Sombra ultra suave estilo iOS
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: baseAccent.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(PremiumDesign.s32), // Más padding interno
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.format_quote_rounded,
                        color: baseAccent,
                        size: widget.isLarge ? 32 : 24,
                      ),
                    ),
                    if (_isPlaying)
                      _AudioWaves(controller: _pulseController, color: baseAccent),
                  ],
                ),
                
                const SizedBox(height: 12),

                Center(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: widget.isLarge ? 26 : 20,
                      fontWeight: widget.isLarge ? FontWeight.w800 : FontWeight.w600,
                      color: PremiumDesign.softText,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Acciones: Primaria (Compartir) vs Secundarias (Like/Audio)
                Row(
                  children: [
                    // Acción Primaria: Compartir
                    Expanded(
                      flex: 3,
                      child: _PrimaryActionButton(
                        icon: Icons.ios_share_rounded,
                        label: 'Compartir 💛',
                        onTap: () async => await Share.share(widget.text),
                        accentColor: baseAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Acciones Secundarias agrupadas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SecondaryActionButton(
                            isFavorite: widget.isFavorite,
                            onTap: _handleLike,
                            controller: _likeController,
                          ),
                          const SizedBox(width: 8),
                          _AudioButton(
                            isPlaying: _isPlaying,
                            onTap: _handleSpeak,
                            pulseController: _pulseController,
                            accentColor: baseAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: PremiumDesign.softText,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: PremiumDesign.softText.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(icon, color: Colors.white, size: 18),
             const SizedBox(width: 8),
             Text(
               label,
               style: GoogleFonts.plusJakartaSans(
                 color: Colors.white,
                 fontWeight: FontWeight.w800,
                 fontSize: 14,
                 letterSpacing: 0.3,
               ),
             ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.isFavorite,
    required this.onTap,
    required this.controller,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final Animation<double> scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 60),
    ]).animate(controller);

    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isFavorite ? Colors.red.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            color: isFavorite ? Colors.redAccent : PremiumDesign.secondaryText.withValues(alpha: 0.4),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  const _AudioButton({
    required this.isPlaying,
    required this.onTap,
    required this.pulseController,
    required this.accentColor,
  });

  final bool isPlaying;
  final VoidCallback onTap;
  final AnimationController pulseController;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isPlaying)
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.6).animate(pulseController),
              child: FadeTransition(
                opacity: Tween(begin: 0.4, end: 0.0).animate(pulseController),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPlaying ? accentColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
              color: isPlaying ? accentColor : PremiumDesign.secondaryText.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioWaves extends StatelessWidget {
  const _AudioWaves({required this.controller, required this.color});
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final double value = (controller.value + (index * 0.3)) % 1.0;
            return Container(
              width: 2.5,
              height: 10 + (8 * (index == 1 ? value : 1 - value)),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
