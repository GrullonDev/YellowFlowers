import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

import 'package:yellow_flowers/features/widgets/flower.dart';

class FlowerScreen extends StatefulWidget {
  const FlowerScreen({super.key});

  @override
  State<FlowerScreen> createState() => _FlowerScreenState();
}

class _FlowerScreenState extends State<FlowerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Offset> _flowerPositions = [];
  final int _flowerCount = 85;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _generateRandomFlowerPositions();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 500,
      end: 100,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _generateRandomFlowerPositions();
      });
    });
  }

  void _generateRandomFlowerPositions() {
    _flowerPositions = List.generate(
      _flowerCount,
      (index) => Offset(
        math.Random().nextDouble() * 650,
        math.Random().nextDouble() * 950,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flores Amarillas'),
      ),
      body: Container(
        color: Colors.lightBlue[100], // Cielo
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.green[200], // Césped
            ),
            ...List.generate(
              _flowerCount,
              (index) => Positioned(
                left: _flowerPositions[index].dx,
                top: _flowerPositions[index].dy,
                child: const Flor(),
              ),
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      'Gracias por ser parte de mi vida, \ncontigo todo es mejor. ❤️❤️',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
