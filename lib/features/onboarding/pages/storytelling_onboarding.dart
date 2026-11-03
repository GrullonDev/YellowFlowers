import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/core/transitions.dart';
import 'package:yellow_flowers/core/user_gender.dart';
import 'package:yellow_flowers/features/home/pages/home_page.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/personalization_service.dart';

class _PageData {
  _PageData({
    required this.title,
    required this.description,
    required this.color,
    this.type = _PageType.info,
  });
  final String title;
  final String description;
  final Color color;
  final _PageType type;
}

enum _PageType { info, gender, streak, name }

class StorytellingOnboarding extends StatefulWidget {
  const StorytellingOnboarding({super.key, this.onComplete});
  final VoidCallback? onComplete;

  @override
  State<StorytellingOnboarding> createState() => _StorytellingOnboardingState();
}

class _StorytellingOnboardingState extends State<StorytellingOnboarding>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  UserGender? _selectedGender;

  late final AnimationController _pulseController;

  final List<_PageData> _pages = [
    _PageData(
      title: 'Expresa lo que sientes',
      description:
          'Convierte tus emociones en un jardín digital lleno de vida.',
      color: PremiumDesign.pastelPink,
    ),
    _PageData(
      title: 'Cuéntanos sobre ti',
      description:
          'Personaliza tu experiencia para que cada detalle se sienta hecho para ti.',
      color: PremiumDesign.softLavender,
      type: _PageType.gender,
    ),
    _PageData(
      title: 'Tu jardín crece contigo',
      description:
          'Cada día que vuelves, una nueva flor aparece en tu jardín. '
          'Las visitas consecutivas hacen florecer algo especial.',
      color: PremiumDesign.cream,
      type: _PageType.streak,
    ),
    _PageData(
      title: '¿Cómo te llamas?',
      description: 'Queremos que este jardín se sienta tan único como tú.',
      color: PremiumDesign.radiantGold,
      type: _PageType.name,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
              switch (page.type) {
                case _PageType.gender:
                  return _GenderSelectionView(
                    page: page,
                    selectedGender: _selectedGender,
                    onGenderSelected: (g) =>
                        setState(() => _selectedGender = g),
                  );
                case _PageType.streak:
                  return _StreakAwarenessView(
                    page: page,
                    pulseController: _pulseController,
                  );
                case _PageType.name:
                  return _NameInputView(
                    page: page,
                    nameController: _nameController,
                  );
                case _PageType.info:
                  return _InfoPageView(page: page);
              }
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
    final currentType = _pages[_currentPage].type;

    return GestureDetector(
      onTap: () async {
        if (currentType == _PageType.gender && _selectedGender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Selecciona una opción para continuar 🌸'),
              backgroundColor: PremiumDesign.radiantGold,
            ),
          );
          return;
        }

        if (isLast) {
          final name = _nameController.text.trim();
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Por favor, dinos tu nombre para continuar 🌸'),
                backgroundColor: PremiumDesign.radiantGold,
              ),
            );
            return;
          }
          final personalization = sl<PersonalizationService>();
          await personalization.saveUserName(name);
          await personalization
              .saveGender(_selectedGender ?? UserGender.unspecified);
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
          HapticFeedback.selectionClick();
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

// --- Page Views ---

class _InfoPageView extends StatelessWidget {
  const _InfoPageView({required this.page});
  final _PageData page;

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
                height: 240,
                child: Lottie.asset(
                  'assets/lottie/flower_bloom.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: PremiumDesign.s32),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: PremiumDesign.serifHeading.copyWith(
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PremiumDesign.s16),
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
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderSelectionView extends StatelessWidget {
  const _GenderSelectionView({
    required this.page,
    required this.selectedGender,
    required this.onGenderSelected,
  });
  final _PageData page;
  final UserGender? selectedGender;
  final ValueChanged<UserGender> onGenderSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = PremiumDesign.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PremiumDesign.s32),
      color: page.color.withValues(alpha: 0.03),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: PremiumDesign.s64),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PremiumDesign.radiantGold.withValues(alpha: 0.2),
                      PremiumDesign.softLavender.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('💫', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: PremiumDesign.s24),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: PremiumDesign.serifHeading.copyWith(
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PremiumDesign.s12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s8),
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
              const SizedBox(height: PremiumDesign.s32),
              ...UserGender.values.map((gender) {
                final selected = selectedGender == gender;
                return Padding(
                  padding: const EdgeInsets.only(bottom: PremiumDesign.s12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onGenderSelected(gender);
                    },
                    child: AnimatedContainer(
                      duration: PremiumDesign.fast,
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: PremiumDesign.s20,
                          vertical: PremiumDesign.s16),
                      decoration: BoxDecoration(
                        color: selected
                            ? (isDark
                                ? PremiumDesign.radiantGold.withValues(alpha: 0.15)
                                : PremiumDesign.radiantGold.withValues(alpha: 0.08))
                            : (isDark
                                ? PremiumDesign.darkCard
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? PremiumDesign.radiantGold
                              : (isDark
                                  ? PremiumDesign.darkDivider
                                  : Colors.grey.withValues(alpha: 0.15)),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: PremiumDesign.radiantGold
                                      .withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : PremiumDesign.softShadow,
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: PremiumDesign.fast,
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? PremiumDesign.radiantGold
                                      .withValues(alpha: 0.15)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.withValues(alpha: 0.06)),
                            ),
                            child: Center(
                              child: Text(
                                gender.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: PremiumDesign.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gender.label,
                                  style:
                                      PremiumDesign.serifSubHeading.copyWith(
                                    fontSize: 18,
                                    color: selected
                                        ? PremiumDesign.radiantGold
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gender.description,
                                  style: PremiumDesign.sansBody.copyWith(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedOpacity(
                            duration: PremiumDesign.fast,
                            opacity: selected ? 1.0 : 0.0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PremiumDesign.radiantGold,
                                boxShadow: PremiumDesign.goldGlow,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakAwarenessView extends StatelessWidget {
  const _StreakAwarenessView({
    required this.page,
    required this.pulseController,
  });
  final _PageData page;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final isDark = PremiumDesign.isDarkMode(context);

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
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  final scale =
                      1.0 + (pulseController.value * 0.08);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PremiumDesign.radiantGold.withValues(alpha: 0.3),
                        PremiumDesign.radiantGold.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text('🌻', style: TextStyle(fontSize: 56)),
                  ),
                ),
              ),
              const SizedBox(height: PremiumDesign.s32),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: PremiumDesign.serifHeading.copyWith(
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PremiumDesign.s16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: PremiumDesign.s8),
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
              const SizedBox(height: PremiumDesign.s32),
              _buildStreakPreview(context, isDark),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakPreview(BuildContext context, bool isDark) {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(PremiumDesign.s20),
      decoration: BoxDecoration(
        color: isDark ? PremiumDesign.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: PremiumDesign.radiantGold.withValues(alpha: 0.2),
        ),
        boxShadow: PremiumDesign.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_florist_rounded,
                  color: PremiumDesign.radiantGold, size: 18),
              const SizedBox(width: 6),
              Text(
                'Así se ve tu jardín semanal',
                style: PremiumDesign.sansBody.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumDesign.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final bloomed = i < 5;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 80),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bloomed
                          ? PremiumDesign.radiantGold.withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.08)),
                      border: bloomed
                          ? Border.all(
                              color: PremiumDesign.radiantGold
                                  .withValues(alpha: 0.4),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        bloomed ? '🌼' : '·',
                        style: TextStyle(
                          fontSize: bloomed ? 18 : 20,
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[i],
                    style: PremiumDesign.sansBody.copyWith(
                      fontSize: 11,
                      fontWeight:
                          bloomed ? FontWeight.w700 : FontWeight.w400,
                      color: bloomed
                          ? PremiumDesign.radiantGold
                          : Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: PremiumDesign.s12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: PremiumDesign.s12, vertical: PremiumDesign.s8),
            decoration: BoxDecoration(
              color: PremiumDesign.radiantGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '5 días seguidos',
                  style: PremiumDesign.sansBody.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesign.radiantGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameInputView extends StatelessWidget {
  const _NameInputView({
    required this.page,
    required this.nameController,
  });
  final _PageData page;
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
                height: 240,
                child: Lottie.asset(
                  'assets/lottie/flower_bloom.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: PremiumDesign.s32),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: PremiumDesign.serifHeading.copyWith(
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: PremiumDesign.s16),
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
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
