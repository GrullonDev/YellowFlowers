import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_illustration.dart';
import 'package:yellow_flowers/utils/app_theme.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

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
  bool _fancyName = false;

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
                    color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: AnimatedBackground(
              topColorBegin: const Color(0xFFFFF3B0),
              topColorEnd: const Color(0xFFFFE8A3),
              bottomColorBegin: const Color(0xFFFFC0CB),
              bottomColorEnd: const Color(0xFFFFB347),
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
                        const Text(
                          'Cultivemos algo hermoso juntas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Campo de texto estilizado
                        TextField(
                          controller: model.nameController,
                          textInputAction: TextInputAction.done,
                          cursorColor: const Color(0xFFFF69B4),
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu nombre 💛',
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.85),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF69B4),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Personalización: tema de flor
                        const Text(
                          'Tema:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChoiceChip(
                              label: const Text('🌼 Margarita'),
                              selected: _theme == FlowerTheme.daisy,
                              onSelected: (_) =>
                                  setState(() => _theme = FlowerTheme.daisy),
                            ),
                            ChoiceChip(
                              label: const Text('🌻 Girasol'),
                              selected: _theme == FlowerTheme.sunflower,
                              onSelected: (_) => setState(
                                  () => _theme = FlowerTheme.sunflower),
                            ),
                            ChoiceChip(
                              label: const Text('🌸 Rosa'),
                              selected: _theme == FlowerTheme.rose,
                              onSelected: (_) =>
                                  setState(() => _theme = FlowerTheme.rose),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Animación dinámica de flores de fondo
                        const Text(
                          'Animación de flores:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChoiceChip(
                              label: const Text('🌬️ Balanceo'),
                              selected: (_animationStyle ??
                                      _theme.defaultAnimation) ==
                                  FlowerAnimationStyle.sway,
                              onSelected: (_) => setState(() =>
                                  _animationStyle = FlowerAnimationStyle.sway),
                            ),
                            ChoiceChip(
                              label: const Text('🌀 Giro'),
                              selected: (_animationStyle ??
                                      _theme.defaultAnimation) ==
                                  FlowerAnimationStyle.spin,
                              onSelected: (_) => setState(() =>
                                  _animationStyle = FlowerAnimationStyle.spin),
                            ),
                            ChoiceChip(
                              label: const Text('💓 Latido'),
                              selected: (_animationStyle ??
                                      _theme.defaultAnimation) ==
                                  FlowerAnimationStyle.pulse,
                              onSelected: (_) => setState(() =>
                                  _animationStyle = FlowerAnimationStyle.pulse),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Personalización: ánimo (gradiente)
                        const Text(
                          'Ánimo:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChoiceChip(
                              label: const Text('💛 Alegría'),
                              selected: _mood == Mood.joy,
                              onSelected: (_) =>
                                  setState(() => _mood = Mood.joy),
                            ),
                            ChoiceChip(
                              label: const Text('🟣 Calma'),
                              selected: _mood == Mood.calm,
                              onSelected: (_) =>
                                  setState(() => _mood = Mood.calm),
                            ),
                            ChoiceChip(
                              label: const Text('💗 Pasión'),
                              selected: _mood == Mood.passion,
                              onSelected: (_) =>
                                  setState(() => _mood = Mood.passion),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tipografía especial para el nombre
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Nombre en tipografía elegante (cursiva)',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          value: _fancyName,
                          onChanged: (v) => setState(() => _fancyName = v),
                        ),
                        const SizedBox(height: 12),
                        // Botón principal con microinteracción
                        AnimatedBuilder(
                          animation: _scale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scale.value,
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTapDown: (_) => _pressController.forward(),
                            onTapCancel: () => _pressController.reverse(),
                            onTapUp: (_) {
                              // No await to avoid async gap before using context
                              _pressController.reverse();
                              final name = model.nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Por favor, escribe tu nombre.')),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HeroControllerScope(
                                    controller: MaterialApp
                                        .createMaterialHeroController(),
                                    child: FlowerScreen(
                                      recipientName: name,
                                      theme: _theme,
                                      mood: _mood,
                                      fancyName: _fancyName,
                                      animationStyle: _animationStyle ??
                                          _theme.defaultAnimation,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD400), // amarillo brillante
                                    Color(0xFFFF69B4), // rosa fuerte
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF69B4)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
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
        },
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {

  const _FeatureChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

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
