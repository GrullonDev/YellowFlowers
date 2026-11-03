import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/widgets/name_entry_flower.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class FlowerOnboardingPage extends StatefulWidget {
  const FlowerOnboardingPage({super.key});

  @override
  State<FlowerOnboardingPage> createState() => _FlowerOnboardingPageState();
}

class _FlowerOnboardingPageState extends State<FlowerOnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _tapCount = 0;
  late final String _rarity;
  late final String _style;

  @override
  void initState() {
    super.initState();
    _rarity = _getRandomRarity();
    _style = _getRandomStyle();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  static String _getRandomRarity() {
    final r = math.Random().nextInt(100);
    if (r < 60) return 'Común 🌼';
    if (r < 90) return 'Rara ✨';
    return 'Legendaria 🌟';
  }

  static String _getRandomStyle() {
    final styles = ['Acuarela', 'Minimalista', '3D', 'Realista', 'Abstracta'];
    return styles[math.Random().nextInt(styles.length)];
  }

  void _onFlowerTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _tapCount = 0;
        _showSecretMessage();
      }
    });
  }

  void _showSecretMessage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(PremiumDesign.s32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: PremiumDesign.premiumRadius,
            boxShadow: PremiumDesign.premiumShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                '¡Mensaje Secreto!',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesign.softText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Has descubierto la magia oculta en este jardín. Eres alguien realmente especial.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: PremiumDesign.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _SmallButton(
                label: 'Continuar',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hour = DateTime.now().hour;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: PremiumDesign.softText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: AnimatedBackground(
        decorationCount: 8,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: PremiumDesign.s24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rarity Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Flor del día: $_style • $_rarity',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: PremiumDesign.secondaryText,
                              ),
                            ),
                          ),
                          const SizedBox(height: PremiumDesign.s24),

                          // Animación de Flor (Bloom) con variación cromática
                          GestureDetector(
                            onTap: _onFlowerTap,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                (hour >= 18 || hour < 6)
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                BlendMode.colorBurn,
                              ),
                              child: SizedBox(
                                height: size.height * 0.32,
                                child: Lottie.asset(
                                  'assets/lottie/flower_bloom.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: PremiumDesign.s32),

                          // Título Emocional
                          Text(
                            'Un detalle nacido del corazón',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: PremiumDesign.softText,
                            ),
                          ),
                          const SizedBox(height: PremiumDesign.s16),

                          // Subtítulo Dinámico
                          Text(
                            'Esta flor $_style $_rarity ha sido cultivada hoy\nespecialmente para ti en este jardín 🌼💛',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: PremiumDesign.secondaryText,
                            ),
                          ),
                          const SizedBox(height: PremiumDesign.s48),

                          // Botón Premium
                          _StartButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NameEntryFlower(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: PremiumDesign.premiumRadius,
        boxShadow: PremiumDesign.premiumShadow,
        gradient: const LinearGradient(
          colors: [Color(0xFF3E2723), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: PremiumDesign.premiumRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Descubrir mi mensaje',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumDesign.softText,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
