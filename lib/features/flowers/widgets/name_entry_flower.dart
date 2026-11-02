import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_result_page.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class NameEntryFlower extends StatefulWidget {
  const NameEntryFlower({super.key});

  @override
  State<NameEntryFlower> createState() => _NameEntryFlowerState();
}

class _NameEntryFlowerState extends State<NameEntryFlower> {
  FlowerTheme _theme = FlowerTheme.daisy;
  Mood _mood = Mood.joy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: PremiumDesign.softText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBackground(
        decorationCount: 8,
        child: SafeArea(
          child: Consumer<FlowerBloc>(
            builder: (context, model, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: PremiumDesign.s24, vertical: PremiumDesign.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: PremiumDesign.s24),

                    // Título Minimalista
                    Text(
                      'Personaliza tu\nflor dorada',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesign.softText,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: PremiumDesign.s12),
                    Text(
                      'Crea una dedicatoria especial que perdure en el tiempo.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: PremiumDesign.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: PremiumDesign.s48),

                    // Campo de Nombre (De)
                    _PremiumField(
                      controller: model.nameController,
                      label: 'Tu nombre',
                      hint: '¿Quién envía la flor?',
                    ),
                    const SizedBox(height: PremiumDesign.s24),

                    // Campo de Destinatario (Para)
                    _PremiumField(
                      controller: model.recipientController,
                      label: 'Para quién es',
                      hint: 'Nombre de la persona especial',
                    ),
                    const SizedBox(height: PremiumDesign.s24),

                    // Campo de Dedicatoria (Mensaje)
                    _PremiumField(
                      controller: model.dedicationController,
                      label: 'Tu mensaje (opcional)',
                      hint: 'Escribe algo desde el corazón...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: PremiumDesign.s32),

                    // Selección de Estilo (Tema)
                    const _SectionHeader(label: 'Elige el estilo visual'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StyleChip(
                          label: 'Daisies',
                          isSelected: _theme == FlowerTheme.daisy,
                          onTap: () =>
                              setState(() => _theme = FlowerTheme.daisy),
                        ),
                        const SizedBox(width: 8),
                        _StyleChip(
                          label: 'Sunflowers',
                          isSelected: _theme == FlowerTheme.sunflower,
                          onTap: () =>
                              setState(() => _theme = FlowerTheme.sunflower),
                        ),
                        const SizedBox(width: 8),
                        _StyleChip(
                          label: 'Roses',
                          isSelected: _theme == FlowerTheme.rose,
                          onTap: () =>
                              setState(() => _theme = FlowerTheme.rose),
                        ),
                      ],
                    ),

                    // Selección de Ánimo (Inteligencia Emocional)
                    const _SectionHeader(
                        label: '¿Cómo te sientes en este momento?'),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _StyleChip(
                            label: 'Alegre ☀️',
                            isSelected: _mood == Mood.joy,
                            onTap: () => setState(() => _mood = Mood.joy),
                          ),
                          const SizedBox(width: 8),
                          _StyleChip(
                            label: 'Relajada 🌿',
                            isSelected: _mood == Mood.calm,
                            onTap: () => setState(() => _mood = Mood.calm),
                          ),
                          const SizedBox(width: 8),
                          _StyleChip(
                            label: 'Nostálgica ☁️',
                            isSelected: _mood ==
                                Mood.passion, // Usaremos pasión como placeholder de nostálgica o mapearemos
                            onTap: () => setState(() => _mood = Mood.passion),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: PremiumDesign.s48),

                    // Botón de Acción Principal
                    _MainButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (model.nameController.text.isEmpty ||
                            model.recipientController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Por favor completa los nombres.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlowerResultPage(
                              sender: model.nameController.text,
                              recipient: model.recipientController.text,
                              dedication: model.dedicationController.text,
                              theme: _theme,
                              mood: _mood,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: PremiumDesign.s32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: PremiumDesign.secondaryText.withValues(alpha: 0.6),
      ),
    );
  }
}

class _PremiumField extends StatelessWidget {
  const _PremiumField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PremiumDesign.softText,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: PremiumDesign.softText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              color: PremiumDesign.secondaryText.withValues(alpha: 0.35),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: Colors.black.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                  color: PremiumDesign.premiumGold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? PremiumDesign.softText
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? PremiumDesign.softShadow : [],
          border: Border.all(
            color: isSelected
                ? PremiumDesign.softText
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : PremiumDesign.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({required this.onTap});
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
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Generar mi flor 💛',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
