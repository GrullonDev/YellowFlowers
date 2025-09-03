import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:yellow_flowers/features/flowers/widgets/name_entry_flower.dart';

class FlowerOnboardingPage extends StatefulWidget {
  const FlowerOnboardingPage({super.key});

  @override
  State<FlowerOnboardingPage> createState() => _FlowerOnboardingPageState();
}

class _FlowerOnboardingPageState extends State<FlowerOnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _topColorAnim = ColorTween(
      begin: const Color(0xFFFFF7C2),
      end: const Color(0xFFFFE8A3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: const Color(0xFFFFD3B6),
      end: const Color(0xFFFFB347),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Animated gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _topColorAnim.value ?? const Color(0xFFFFF7C2),
                    _bottomColorAnim.value ?? const Color(0xFFFFB3C6),
                  ],
                ),
              ),
            ),
            // Floating soft petals/hearts
            ...List.generate(10, (i) {
              final rnd = math.Random(i * 13);
              final dx = rnd.nextDouble();
              final baseY = rnd.nextDouble() * size.height * 0.5;
              final drift =
                  math.sin(_bgController.value * 2 * math.pi + i) * 12;
              return Positioned(
                left: dx * size.width,
                top: baseY + drift,
                child: Opacity(
                  opacity: 0.10 + 0.10 * rnd.nextDouble(),
                  child: Transform.rotate(
                    angle:
                        math.sin(_bgController.value * 2 * math.pi + i) * 0.2,
                    child: Icon(
                      i.isEven ? Icons.favorite : Icons.local_florist,
                      color: i.isEven
                          ? Colors.pinkAccent
                          : const Color(0xFFFFE07D),
                      size: 16 + rnd.nextDouble() * 12,
                    ),
                  ),
                ),
              );
            }),
            // Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lottie flower opening (placeholder asset path)
                      SizedBox(
                        height: size.height * 0.34,
                        child: Lottie.asset(
                          'assets/lottie/flower_bloom.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Te regalo un detalle especial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hoy recibirás un mensaje solo para ti 🌼💛',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NameEntryFlower(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text(
                            'Descubrir mi mensaje',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
