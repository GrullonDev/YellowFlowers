import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_illustration.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class NameEntryFlower extends StatefulWidget {
  const NameEntryFlower({super.key});

  @override
  State<NameEntryFlower> createState() => _NameEntryFlowerState();
}

class _NameEntryFlowerState extends State<NameEntryFlower>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;
  FlowerTheme _theme = FlowerTheme.daisy;
  Mood _mood = Mood.joy;
  FlowerAnimationStyle? _animationStyle; // null => usa el sugerido por tema

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FlowerBloc(),
      child: Builder(
        builder: (context) {
          final model = context.watch<FlowerBloc>();

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundCream,
                    AppTheme.accentPink.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ilustración central
                        const SizedBox(
                          height: 220,
                          child: Center(
                            child: Hero(
                              tag: 'hero-flor',
                              child:
                                  FlowerIllustration(width: 160, height: 220),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Título amigable
                        Text(
                          'Bienvenida',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cultivemos algo hermoso juntas',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 32),

                        // Tarjeta de Entrada
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.textDark.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Campo de texto estilizado
                              TextField(
                                controller: model.nameController,
                                textInputAction: TextInputAction.done,
                                cursorColor: AppTheme.accentPink,
                                style: Theme.of(context).textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: 'Tu Nombre',
                                  labelStyle: TextStyle(
                                      color: AppTheme.textDark
                                          .withValues(alpha: 0.6)),
                                  hintText: '¿Cómo te llamas? ✨',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textDark
                                        .withValues(alpha: 0.4),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.backgroundCream,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppTheme.accentPink,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppTheme.sunnyGold),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Personalización: tema de flor
                              Text(
                                'Elige tu Flor:',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _FeatureChip(
                                    label: 'Margarita 🌼',
                                    selected: _theme == FlowerTheme.daisy,
                                    onSelected: () => setState(
                                        () => _theme = FlowerTheme.daisy),
                                  ),
                                  _FeatureChip(
                                    label: 'Girasol 🌻',
                                    selected: _theme == FlowerTheme.sunflower,
                                    onSelected: () => setState(
                                        () => _theme = FlowerTheme.sunflower),
                                  ),
                                  _FeatureChip(
                                    label: 'Rosa 🌸',
                                    selected: _theme == FlowerTheme.rose,
                                    onSelected: () => setState(
                                        () => _theme = FlowerTheme.rose),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Personalización: ánimo
                              Text(
                                '¿Qué energía deseas hoy?',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _FeatureChip(
                                    label: 'Alegría 💛',
                                    selected: _mood == Mood.joy,
                                    onSelected: () =>
                                        setState(() => _mood = Mood.joy),
                                  ),
                                  _FeatureChip(
                                    label: 'Calma 🟣',
                                    selected: _mood == Mood.calm,
                                    onSelected: () =>
                                        setState(() => _mood = Mood.calm),
                                  ),
                                  _FeatureChip(
                                    label: 'Amor 💗',
                                    selected: _mood == Mood.passion,
                                    onSelected: () =>
                                        setState(() => _mood = Mood.passion),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Botón principal
                              AnimatedBuilder(
                                animation: _scale,
                                builder: (context, child) => Transform.scale(
                                  scale: _scale.value,
                                  child: child,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _pressController.forward().then(
                                        (_) => _pressController.reverse());
                                    final name =
                                        model.nameController.text.trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              '¡Por favor, dinos tu nombre! 🌸'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HeroControllerScope(
                                          controller: MaterialApp
                                              .createMaterialHeroController(),
                                          child: FlowerScreen(
                                            recipientName: name,
                                            theme: _theme,
                                            mood: _mood,
                                            fancyName:
                                                true, // Always fancy by default now
                                            animationStyle: _animationStyle ??
                                                _theme.defaultAnimation,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Comenzar Experiencia'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FeatureChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.leafGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.leafGreen
                : AppTheme.textDark.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.leafGreen.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected ? Colors.white : AppTheme.textDark,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
