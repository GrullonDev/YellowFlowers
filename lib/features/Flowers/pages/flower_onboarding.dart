import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:yellow_flowers/features/flowers/widgets/name_entry_flower.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class FlowerOnboardingPage extends StatefulWidget {
  const FlowerOnboardingPage({super.key});

  @override
  State<FlowerOnboardingPage> createState() => _FlowerOnboardingPageState();
}

class _FlowerOnboardingPageState extends State<FlowerOnboardingPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
      body: AnimatedBackground(
        decorationCount: 10,
        child: SafeArea(
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
      ),
    );
  }
}
