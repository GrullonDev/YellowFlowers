import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/flowers/widgets/flower.dart';

class FlowerScreen extends StatefulWidget {
  final String recipientName;
  const FlowerScreen({super.key, required this.recipientName});

  @override
  State<FlowerScreen> createState() => _FlowerScreenState();
}

class _FlowerScreenState extends State<FlowerScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _flowerControllers = [];
  late AnimationController _messageAnimationController;
  late Timer _timer;
  late List<AnimationController> _sparkleControllers = [];
  final int _sparkleCount = 50;

  final int _flowerCount = 60;
  final List<String> _messages = [
    "Gracias por ser parte de mi vida, contigo todo es mejor. ❤️❤️",
    "Eres la flor más hermosa de mi jardín. 🌼",
    "Tu sonrisa ilumina mis días. ☀️ ☀️ ☀️",
    "Contigo, cada momento es especial. ✨",
    "Eres mi compañera, amiga y amor. 💖",
  ];

  @override
  void initState() {
    super.initState();

    _flowerControllers = List.generate(
      _flowerCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(microseconds: 5),
      )..repeat(reverse: true),
    );

    _sparkleControllers = List.generate(
      _sparkleCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 1500 + math.Random().nextInt(1500),
        ),
      )..repeat(reverse: true),
    );

    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _resetFlowerPositions();
      _showRandomMessage();
      _resetSparkleAnimations();
      setState(() {});
    });
  }

  void _resetFlowerPositions() {
    for (int i = 0; i < _flowerCount; i++) {
      _flowerControllers[i].reset();
      _flowerControllers[i].forward();
    }
  }

  void _resetSparkleAnimations() {
    for (int i = 0; i < _sparkleCount; i++) {
      _sparkleControllers[i].reset();
      _sparkleControllers[i].forward();
    }
  }

  void _showRandomMessage() {
    setState(() {
      // No necesitamos lógica adicional aquí
    });
  }

  Color _getBackgroundColor() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      return const Color.fromRGBO(255, 248, 220, 1);
    } else if (hour >= 12 && hour < 18) {
      return const Color.fromRGBO(255, 228, 196, 1);
    } else if (hour >= 18 && hour < 22) {
      return const Color.fromRGBO(255, 182, 193, 1);
    } else {
      return const Color.fromRGBO(173, 216, 230, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calcular la altura del mensaje de manera dinámica
    final messageHeight =
        screenHeight * 0.10; // 10% de la altura de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flores Amarillas'),
      ),
      body: Stack(
        children: [
          Container(
            color: _getBackgroundColor(),
          ),

          // Mensaje
          Positioned(
            top: screenHeight * 0.05, // Ajuste para posicionar el mensaje
            left: screenWidth * 0.1,
            width: screenWidth * 0.8,
            child: Opacity(
              opacity: _messageAnimationController.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "${widget.recipientName}, ${_messages[math.Random().nextInt(_messages.length)]}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Destellos
          ...List.generate(
            _sparkleCount,
            (index) => AnimatedBuilder(
              animation: _sparkleControllers[index],
              builder: (context, child) {
                final x = math.Random().nextDouble() * screenWidth;
                final y = messageHeight +
                    math.Random().nextDouble() *
                        (screenHeight * 0.4); // Acorta el rango de destellos
                final size = 3.0 + _sparkleControllers[index].value * 5.0;
                final opacity = 0.5 + _sparkleControllers[index].value * 0.5;

                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Flores
          ...List.generate(
            _flowerCount,
            (index) => AnimatedBuilder(
              animation: _flowerControllers[index],
              builder: (context, child) {
                final x = math.Random().nextDouble() * screenWidth;
                final y = screenHeight * 0.25 +
                    math.Random().nextDouble() *
                        (screenHeight *
                            0.4); // Ajuste la posición Y para que no se superponga
                final scale = 1.4 +
                    math.sin(_flowerControllers[index].value * 2 * math.pi) *
                        0.10;
                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      // Envuelve Flor con SizedBox
                      width: screenWidth / 8, // Ancho de la flor
                      height: screenHeight /
                          2, // Altura suficiente para mostrar toda la flor
                      child: const Flor(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _flowerControllers) {
      controller.dispose();
    }
    for (var controller in _sparkleControllers) {
      controller.dispose();
    }
    _messageAnimationController.dispose();
    _timer.cancel();
    super.dispose();
  }
}

/* final int _flowerCount = 60; // Reducimos un poco para mejor rendimiento
final List<String> _messages = [
  "Gracias por ser parte de mi vida, contigo todo es mejor. ❤️❤️",
  "Eres la flor más hermosa de mi jardín. 🌼",
  "Tu sonrisa ilumina mis días. ☀️ ☀️ ☀️",
  "Contigo, cada momento es especial. ✨",
  "Eres mi compañera, amiga y amor. 💖",
]; */
