import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/personalization_service.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
}

class StorytellingOnboarding extends StatefulWidget {
  final VoidCallback? onComplete;
  const StorytellingOnboarding({super.key, this.onComplete});

  @override
  State<StorytellingOnboarding> createState() => _StorytellingOnboardingState();
}

class _StorytellingOnboardingState extends State<StorytellingOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Expresa lo que sientes',
      description: 'Convierte tus emociones en un jardín digital lleno de vida.',
      lottieAsset: 'assets/lottie/flower_bloom.json',
      color: PremiumDesign.pastelPink,
    ),
    OnboardingPage(
      title: 'Crea momentos únicos',
      description: 'Diseña flores personalizadas para cada ocasión especial.',
      lottieAsset: 'assets/lottie/flower_bloom.json', // Using same for now as we only have one
      color: PremiumDesign.softLavender,
    ),
    OnboardingPage(
      title: 'Comparte emociones',
      description: 'Envía tus creaciones y alegra el día de alguien especial.',
      lottieAsset: 'assets/lottie/flower_bloom.json', // Using same for now
      color: PremiumDesign.cream,
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
              return _OnboardingContentView(page: page);
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
            color: active ? PremiumDesign.radiantGold : Colors.grey.withValues(alpha: 0.3),
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
          await personalization.setNotFirstTime();
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
              style: PremiumDesign.sansLabel.copyWith(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: PremiumDesign.s8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContentView extends StatelessWidget {
  final OnboardingPage page;
  const _OnboardingContentView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumDesign.s48),
      color: page.color.withValues(alpha: 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: Lottie.asset(
              page.lottieAsset,
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: PremiumDesign.s64),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: PremiumDesign.serifHeading.copyWith(
              fontSize: 34,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: PremiumDesign.s24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s32),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: PremiumDesign.sansBody.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

