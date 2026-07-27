import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yellow_flowers/core/analytics/analytics_service.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/personalization_service.dart';

class OnboardingPage {
  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
    this.isNamePage = false,
  });
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;
  final bool isNamePage;
}

class StorytellingOnboarding extends StatefulWidget {
  const StorytellingOnboarding({super.key, this.onComplete});
  final VoidCallback? onComplete;

  @override
  State<StorytellingOnboarding> createState() => _StorytellingOnboardingState();
}

class _StorytellingOnboardingState extends State<StorytellingOnboarding> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Expresa lo que sientes',
      description:
          'Convierte tus emociones en un jardín digital lleno de vida.',
      lottieAsset: 'assets/lottie/flower_bloom.json',
      color: PremiumDesign.pastelPink,
    ),
    OnboardingPage(
      title: 'Crea momentos únicos',
      description: 'Diseña flores personalizadas para cada ocasión especial.',
      lottieAsset:
          'assets/lottie/flower_bloom.json', // Using same for now as we only have one
      color: PremiumDesign.softLavender,
    ),
    OnboardingPage(
      title: 'Comparte emociones',
      description: 'Envía tus creaciones y alegra el día de alguien especial.',
      lottieAsset: 'assets/lottie/flower_bloom.json', // Using same for now
      color: PremiumDesign.cream,
    ),
    OnboardingPage(
      title: '¿Cómo te llamas?',
      description: 'Queremos que este jardín se sienta tan único como tú.',
      lottieAsset: 'assets/lottie/flower_bloom.json',
      color: PremiumDesign.radiantGold,
      isNamePage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingContentView(
                page: page,
                nameController: _nameController,
              );
            },
          ),
          Positioned(
            bottom: PremiumDesign.s48,
            left: PremiumDesign.s32,
            right: PremiumDesign.s32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDotIndicator(),
                _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      children: List.generate(_pages.length, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: PremiumDesign.fast,
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active
                ? PremiumDesign.radiantGold
                : Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentPage == _pages.length - 1;
    final personalization = sl<PersonalizationService>();

    return GestureDetector(
      onTap: () async {
        if (isLast) {
          final name = _nameController.text.trim();
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, dinos tu nombre para continuar 🌸'),
                backgroundColor: PremiumDesign.radiantGold,
              ),
            );
            return;
          }
          await personalization.saveUserName(name);
          await personalization.setNotFirstTime();
          unawaited(sl<AnalyticsService>().logOnboardingCompleted());
          if (mounted) {
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else {
              Navigator.pushReplacement(
                context,
                PremiumTransitions.fadeThrough(const HomePage()),
              );
            }
          }
        } else {
          _pageController.nextPage(
            duration: PremiumDesign.medium,
            curve: Curves.easeInOutQuart,
          );
        }
      },
      child: AnimatedContainer(
        duration: PremiumDesign.fast,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: PremiumDesign.radiantGold,
          borderRadius: BorderRadius.circular(32),
          boxShadow: PremiumDesign.goldGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast ? 'Empezar' : 'Siguiente',
              style: PremiumDesign.sansLabel
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: PremiumDesign.s8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContentView extends StatelessWidget {
  const _OnboardingContentView(
      {required this.page, required this.nameController});
  final OnboardingPage page;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s32),
      color: page.color.withValues(alpha: 0.03),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: PremiumDesign.s48),
              SizedBox(
                height: 240, // Reduced from 300 to give more breathing room
                child: Lottie.asset(
                  page.lottieAsset,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: PremiumDesign.s32), // Reduced from 64
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: PremiumDesign.serifHeading.copyWith(
                  fontSize: 32, // Slightly smaller
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PremiumDesign.s16), // Reduced from 24
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s16),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: PremiumDesign.sansBody.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              if (page.isNamePage) ...[
                const SizedBox(height: PremiumDesign.s32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: PremiumDesign.premiumShadow,
                    border: Border.all(
                      color: PremiumDesign.radiantGold.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: PremiumDesign.sansBody.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: PremiumDesign.softText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tu nombre aquí...',
                      hintStyle: PremiumDesign.sansBody.copyWith(
                        color:
                            PremiumDesign.secondaryText.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
              const SizedBox(
                  height: 120), // Extra space for the floating buttons
            ],
          ),
        ),
      ),
    );
  }
}
