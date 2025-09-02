import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_screen.dart';
import 'package:yellow_flowers/features/flowers/widgets/flower_illustration.dart';

class NameEntryFlower extends StatefulWidget {
  const NameEntryFlower({super.key});

  @override
  State<NameEntryFlower> createState() => _NameEntryFlowerState();
}

class _NameEntryFlowerState extends State<NameEntryFlower>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;

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
              title: const Text(''),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF3B0), // amarillo pastel
                    Color(0xFFFFC0CB), // rosa suave
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
                        const Text(
                          'Bienvenida',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Escribe tu nombre para comenzar',
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
                            onTapUp: (_) async {
                              await _pressController.reverse();
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
                                    child: FlowerScreen(recipientName: name),
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
                                        .withOpacity(0.35),
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
